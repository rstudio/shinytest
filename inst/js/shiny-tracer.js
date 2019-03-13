window.shinytest = (function() {
    var shinytest = {
        connected: false,
        busy: null,
        updating: [],
        log_entries: [],
        entries_shown: 0,
        log_messages: false
    };

    shinytest.log = function(message) {
        shinytest.log_entries.push({
            timestamp: new Date().toISOString(),
            message: message
        });
    };
    shinytest.log("window.shinytest loaded");


    shinytest.inputQueue = (function() {
        var inputqueue = {};

        var queue = [];

        // Add a set of inputs to the queue. Format of `inputs` must be
        // `{ input1: value1, input2: value2 }`.
        inputqueue.add = function(inputs) {
            for (var name in inputs) {
                shinytest.log("inputQueue: adding " + name);
                var input = inputs[name];
                queue.push({
                    name: name,
                    value: input.value,
                    allowInputNoBinding: input.allowInputNoBinding,
                    priority: input.priority
                });
            }
        };

        inputqueue.flush = function() {
            function flushItem(item) {
                shinytest.log("inputQueue: flushing " + item.name);
                var binding = findInputBinding(item.name);
                if (binding) {
                    var value = preprocess(item.name, item.value);
                    var $el = $("#" + escapeSelector(item.name));

                    binding.setValue($el[0], value);
                    $el.trigger("change");

                } else {
                    // For inputs without a binding: if the script says it's
                    // OK, just set the value directly. Otherwise throw an
                    // error.
                    if (item.allowInputNoBinding) {
                        var priority = item.priority === "event" ? {priority: "event"} : undefined;
                        Shiny.setInputValue(item.name, item.value, priority);
                    } else {
                        var msg = "Unable to find input binding for element with id " + item.name;
                        shinytest.log("  " + msg);
                        throw msg;
                    }
                }
            }

            try {
                queue.map(flushItem);
            } finally {
                queue = [];
            }
        };

        // Some input need their values preprocessed, because the value passed
        // to the R function `app$setInputs()`, differs in structure from the
        // value used in the JavaScript function `InputBinding.setValue()`.
        // For example, for dateRangeInputs, `setInputs()` is passed a two-
        // element vector or list, while the `setValue()` requires an object
        // with `start` and `end`.
        inputqueue.preprocessors = {
            "shiny.dateRangeInput": function(el, value) {
                if (!(value instanceof Array)) {
                    throw "Value for dateRangeInput must be an array.";
                }

                return {
                    start: value[0],
                    end:   value[1]
                };
            },

            "shiny.actionButtonInput": function(el, value) {
                if (value !== "click") {
                    throw 'The only valid value for an actionButton is "click".';
                }

                // Instead of setting a value, we'll just trigger a click.
                $(el).trigger("click");
            },

            "shiny.fileInputBinding": function(el, value) {
                throw "Setting value of fileInput is not supported. Use app$uploadFile() instead";
            },

            "shiny.sliderInput": function(el, value) {
                if (typeof(value) === "string" &&
                    /\d\d\d\d-\d\d-\d\d/.test(value))
                {
                    shinytest.log(new Date(value).getTime() );
                    return new Date(value).getTime();
                } else {
                    return value;
                }
            }
        };

        // Given a DOM ID, return the input binding for that element; if not
        // found, return null.
        function findInputBinding(id) {
            var $el = $("#" + escapeSelector(id));
            if ($el.length === 0 || !$el.data("shinyInputBinding")) {
                return null;
            }

            return $el.data("shinyInputBinding");
        }

        // Given a DOM ID and value, find the input binding for that DOM
        // element and run appropriate preprocessor, if present. If no
        // preprocessor, simply return the value.
        function preprocess(id, value) {
            var binding = findInputBinding(id);
            if (!binding) {
                return value;
            }

            var $el = $("#" + escapeSelector(id));

            if (inputqueue.preprocessors[binding.name])
                return inputqueue.preprocessors[binding.name]($el[0], value);
            else
                return value;
        }

        return inputqueue;
    })();


    // Wrapper for async waiting of a message with output values. Should be
    // invoked like this:
    //
    // shinytest.outputValuesWaiter.start(timeout);
    // doSomething();
    // shinytest.outputValuesWaiter.finish(wait, callback);
    //
    // Where `doSomething` is a function that does the desired work. It could
    // even be work that's done in a separate process. The reason that the
    // callback function must be passed to the `finish()` instead of `start()`
    // is because calling `executeScriptAsync()` from the R side is
    // synchronous; it returns only when `callback()` is invoked.
    //
    // start() can also be called with a second argument, n_messages. This is
    // the number of messages that it will wait for before the finish callback
    // is invoked. If the value is not supplied, it will wait for just one
    // message before invoking the callback.
    //
    // If wait==true, then wait for a message from server containing output
    // values before invoking callback. If `timeout` ms elapses without a
    // message arriving, invoke the callback. The callback function is passed
    // an object with one item, `timedOut`, which is a boolean that reports
    // whether the timeout elapsed when waiting for values.
    shinytest.outputValuesWaiter = (function() {
        var n;          // Number of output value messages to wait for
        var found;      // Number of output value messages found so far
        var finishCallback = null;

        function start(timeout, n_messages) {
            if (n_messages === undefined) n_messages = 1;

            if (finishCallback !== null) {
                throw "Can't start while already waiting";
            }

            n = n_messages;
            found = 0;

            waitForEnoughOutputValueMessages(timeout, function(timedOut) {
                if (finishCallback) {
                    var tmp = finishCallback;
                    finishCallback = null;
                    tmp({ timedOut: timedOut });
                }
            });
        }

        function finish(wait, callback) {
            if (!callback)
                throw "finish(): callback function is required.";

            // When finish is called, return (invoke callback) immediately if
            // we have already found the output message, or if we're told not
            // to wait for it. Otherwise store the callback; it will be
            // invoked when the output message arrives.
            if (foundEnough() || !wait) {
                callback({ timedOut: false });
            } else {
                finishCallback = callback;
            }
        }

        // Have enough messages been found?
        function foundEnough() {
            return found >= n;
        }

        // This waits for enough shiny:message events to occur, where the
        // messsage contains a field named `values`. That is a message from
        // the server with output values. Usually we wait for one, but
        // sometimes we need to wait for more than one message. When that
        // occurs, invoke `callback(false)`. Or, if timeout elapses without
        // seeing such a message, invoke `callback(true)`.
        function waitForEnoughOutputValueMessages(timeout, callback) {
            if (timeout === undefined) timeout = 3000;

            // This is a bit of a hack: we want the callback to be invoked _after_
            // the outputs are assigned. Because the shiny:message event is
            // triggered just before the output values are assigned, we need to
            // wait for the next tick of the eventloop.
            var callbackWrapper = function(timedOut) {
                setTimeout(function() { callback(timedOut); }, 0);
            };

            // Check that a message contains `values` field.
            function checkMessage(e) {
                if (e.message && e.message.values) {
                    found++;
                    shinytest.log("Found message with values field.");

                    if (foundEnough()) {
                        $(document).off("shiny:message", checkMessage);
                        clearTimeout(timeoutCallback);

                        callbackWrapper(false);
                    }
                }
            }

            $(document).on("shiny:message", checkMessage);

            // If timeout elapses without finding message, remove listener and
            // invoke `callback(true)`.
            var timeoutCallback = setTimeout(function() {
                shinytest.log("Timed out without finding message with values field.");

                $(document).off("shiny:message", checkMessage);

                callbackWrapper(true);
            }, timeout);
        }

        return {
            start: start,
            finish: finish
        };
    })();


    shinytest.listWidgets = function() {
        function getids(els) {
            return els.map(function(){ return $(this).attr("id"); }).get();
        }

        // This is a trick to find duplicate ids
        function get(selector) {
            var els = $(selector);
            return getids(els)
                .map(function(x) {
                    var id = '#' + escapeSelector(x) + ',' + '#' + escapeSelector(x);
                    return getids($(id));
                });
        }

        return {
            'input':  get('.shiny-bound-input'),
            'output': get('.shiny-bound-output')
        };
    };

    // Returns values from input or output bindings
    shinytest.getAllValues = function(ids) {
        return {
            inputs: Shiny.shinyapp.$inputValues,
            outputs: Shiny.shinyapp.$values,
            errors: Shiny.shinyapp.$errors
        };
    };

    // This sets shinytest.ready to true when the Shiny application is ready.
    function waitForReady() {
        // Check if we're already connected and the Shiny session has been
        // initialized by the time this code executes. If not, set up a callback
        // for the shiny:sessioninitialized event.
        if (typeof Shiny !== "undefined" && Shiny.shinyapp &&
            Shiny.shinyapp.config && Shiny.shinyapp.config.sessionId)
        {
            shinytest.log("already connected");
            waitForHtmlOutput();
        }
        else {
            shinytest.log("waiting for shiny session to connect");
            $(document).one("shiny:sessioninitialized", function(e) {
                shinytest.log("connected");
                waitForHtmlOutput();
            });
        }

        // If there are any HTML outputs, don't say we're ready until we
        // receive one message with output values. If there are no HTML
        // outputs, just say we're ready now.
        function waitForHtmlOutput() {
            var htmlOutputBindings = Shiny.outputBindings
                .bindingNames['shiny.htmlOutput'].binding.find(document);

            if (htmlOutputBindings.length > 0) {
                shinytest.log("waiting for first output");
                shinytest.outputValuesWaiter.start(5000);
                shinytest.outputValuesWaiter.finish(true, function() {
                    shinytest.ready = true;
                });
            }
            else {
                shinytest.log("ready");
                shinytest.ready = true;
            }
        }
    }
    waitForReady();


    $(document).on("shiny:busy", function(e) {
        shinytest.busy = true;
        shinytest.log("busy");
    });

    $(document).on("shiny:idle", function(e) {
        shinytest.busy = false;
        shinytest.log("idle");
    });

    $(document).on("shiny:message", function(e) {
        if (shinytest.log_messages)
            shinytest.log("message: " + JSON.stringify(e.message));
    });

    $(document).on("shiny:value", function(e) {
        shinytest.log("value " + e.name);

        // Clear up updates
        var idx = shinytest.updating.indexOf(e.name);
        if (idx != -1) {
            shinytest.updating.splice(idx, 1);
        }
    });


    // Escape meta characters in jQuery selectors: !"#$%&'()*+,-./:;<=>?@[\]^`{|}~
    function escapeSelector(s) {
        return s.replace(/([!"#$%&'()*+,-./:;<=>?@\[\\\]^`{|}~])/g, "\\$1");
    }

    return shinytest;
})();
