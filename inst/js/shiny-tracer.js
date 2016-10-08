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


    shinytest.inputqueue = (function() {
        var inputqueue = {};

        var queue = [];

        // Add a set of inputs to the queue. Format of `inputs` must be
        // `{ input1: value1, input2: value2 }`.
        inputqueue.add = function(inputs) {
            for (var name in inputs) {
                shinytest.log("inputqueue: pushing " + name + ":" + inputs[name]);
                queue.push({
                    name: name,
                    value: inputs[name]
                });
            }
        };

        inputqueue.flush = function() {
            queue.map(function(item) {
                shinytest.log("inputqueue: flushing " + item.name + ":" + item.value);
                var $el = $("#" + item.name);
                $el.data("shinyInputBinding").setValue($el[0], item.value);
                $el.trigger("change");
            });

            queue = [];
        };

        return inputqueue;
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
		    return getids($(id))
		});
	}

	return { 'input':  get('.shiny-bound-input'),
		 'output': get('.shiny-bound-output') };
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
