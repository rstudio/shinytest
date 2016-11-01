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


    shinytest.inputQueue = (function() {
        var inputqueue = {};

        var queue = [];

        // Add a set of inputs to the queue. Format of `inputs` must be
        // `{ input1: value1, input2: value2 }`.
        inputqueue.add = function(inputs) {
            for (var name in inputs) {
                shinytest.log("inputQueue: adding " + name);
                queue.push({
                    name: name,
                    value: inputs[name]
                });
            }
        };

        inputqueue.flush = function() {

            function flushItem(item) {
                shinytest.log("inputQueue: flushing " + item.name);
                var $el = $("#" + item.name);
                var binding = findInputBinding($el[0]);
                var value = preprocess($el[0], item.value);

                binding.setValue($el[0], value);
                $el.trigger("change");
            }

            try {
                queue.map(flushItem);
            } finally {
                queue = [];
            }
        };

        // Some input need their values preprocessed, because the value passed
        // to the R function `app$set_inputs()`, differs in structure from the
        // value used in the JavaScript function `InputBinding.setValue()`.
        // For example, for dateRangeInputs, `set_inputs()` is passed a two-
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
                throw "Setting value of fileInput is not supported.";
            }
        };

        // Given a DOM ID, return the input binding for that element; if not
        // found, throw an error.
        function findInputBinding(el) {
            var $el = $(el);
            if ($el.length === 0 || !$el.data("shinyInputBinding")) {
                var msg = "Unable to find input binding for element";
                shinytest.log("  " + msg);
                throw msg;
            }

            return $el.data("shinyInputBinding");
        }

        // Given a DOM ID and value, find the input binding for that DOM
        // element and run appropriate preprocessor, if present. If no
        // preprocessor, simply return the value.
        function preprocess(el, value) {
            var binding = findInputBinding(el);

            if (inputqueue.preprocessors[binding.name])
                return inputqueue.preprocessors[binding.name](el, value);
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
    // is because calling `execute_script_async()` from the R side is
    // synchronous; it returns only when `callback()` is invoked.
    //
    // If wait==true, then wait for a message from server containing output
    // values before invoking callback. If `timeout` ms elapses without a
    // message arriving, invoke the callback.
    shinytest.outputValuesWaiter = (function() {
        var found = false;
        var finishCallback = null;

        function start(timeout) {
            if (finishCallback !== null) {
                throw "Can't start while already waiting";
            }

            found = false;

            waitForOutputValueMessage(timeout, function() {
                found = true;
                if (finishCallback) {
                    var tmp = finishCallback;
                    finishCallback = null;
                    tmp();
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
            if (found || !wait) {
                callback();
            } else {
                finishCallback = callback;
            }
        }


        // This waits for a shiny:message event to occur, where the messsage
        // contains a field named `values`. That is a message from the server with
        // output values. When that occurs, invoke the callback. Or, if timeout
        // elapses without seeing such a message, invoke the callback.
        function waitForOutputValueMessage(timeout, callback) {
            if (timeout === undefined) timeout = 3000;

            // This is a bit of a hack: we want the callback to be invoked _after_
            // the outputs are assigned. Because the shiny:message event is
            // triggered just before the output values are assigned, we need to
            // wait for the next tick of the eventloop.
            var callbackWrapper = function() {
                setTimeout(callback, 0);
            };

            // Check that a message contains `values` field.
            function checkMessage(e) {
                if (e.message && e.message.values) {
                    shinytest.log("Found message with values field.");

                    $(document).off("shiny:message", checkMessage);
                    clearTimeout(timeoutCallback);

                    callbackWrapper();
                }
            }

            $(document).on("shiny:message", checkMessage);

            // If timeout elapses without finding message, remove listener and
            // invoke callback.
            var timeoutCallback = setTimeout(function() {
                shinytest.log("Timed out without finding message with values field.");

                $(document).off("shiny:message", checkMessage);

                callbackWrapper();
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
		    var id = '#' + x + ',' + '#' + x;
		    return getids($(id));
		});
	}

	return { 'input':  get('.shiny-bound-input'),
		 'output': get('.shiny-bound-output') };
    };

    // Returns values from input or output bindings
    shinytest.getAllValues = function(ids) {
        return {
            inputs: Shiny.shinyapp.$inputValues,
            outputs: Shiny.shinyapp.$values,
            errors: Shiny.shinyapp.$errors
        };
    };

    $(document).on("shiny:connected", function(e) {
        shinytest.connected = true;
        shinytest.log("connected");
    });

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

    return shinytest;
})();
