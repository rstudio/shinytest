window.shinytest = (function() {
    var shinytest = {
        connected: false,
        busy: null,
        updating: [],
        log_entries: [],
        entries_shown: 0
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
            queue.map(function(item) {
                shinytest.log("inputQueue: flushing " + item.name);
                var $el = $("#" + item.name);
                $el.data("shinyInputBinding").setValue($el[0], item.value);
                $el.trigger("change");
            });

            queue = [];
        }

        // Async wrapper for flush(). If wait==true, then wait for a message
        // coming back from server before invoking callback. If
        // returnValues==true, pass all input, output, and error values to the
        // callback.
        inputqueue.flushAndWaitAsync = function(wait, returnValues, timeout,
                                                callback)
        {
            if (wait) {
                var callbackWrapper = function() {
                    if (returnValues)
                        callback(shinytest.getAllValues());
                    else
                        callback();
                };

                waitForOutputValues(timeout, callbackWrapper);
            }

            inputqueue.flush();

            if (!wait) {
                if (returnValues)
                    throw "Can't return values without waiting."
                else
                    callback();
            }
        };

        return inputqueue;
    })();


    // This waits for a shiny:message event to occur, where the messsage
    // contains a field named `values`. That is a message from the server with
    // output values. When that occurs, invoke the callback. Or, if timeout
    // elapses without seeing such a message, invoke the callback.
    var waitForOutputValues = function(timeout, callback) {
        if (timeout === undefined) timeout = 1000;

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
		    return getids($(id))
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
