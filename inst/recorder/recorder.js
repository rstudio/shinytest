window.shinyRecorder = (function() {
    var shinyrecorder = {
        inputEvents: [],
        token: null        // Gets set by parent frame
    };

    // Store previous values for each input. Use JSON so that we can compare
    // non-primitive objects like arrays.
    var previousInputValues = {};

    $(document).on("shiny:inputchanged", function(event) {
        // Check if value has changed from last time.
        var valueJSON = JSON.stringify(event.value);
        if (valueJSON === previousInputValues[event.name])
            return;
        previousInputValues[event.name] = valueJSON;

        shinyrecorder.inputEvents.push({
            type: event.inputType,
            name: event.name,
            value: event.value
        });

        // Generate R code to display in window
        var value = shinyrecorder.inputProcessor.apply(event.inputType, event.value);

        sendInputEventToParent(event.name, value);
    });


    // Ctrl-click to record an output value
    $(document).on("click", ".shiny-bound-output", function(e) {
        if (!e.ctrlKey)
            return;

        var id = e.target.id;
        var value = Shiny.shinyapp.$values[id];

        sendCodeToParent("output: " + id + ": " +
            escapeHTML('"' + escapeString(String(value))) + '"\n');
    });


    function sendInputEventToParent(name, value) {
        parent.postMessage({
            token: shinyrecorder.token,
            inputEvent: { name: name, value: value }
        }, "*");
    }

    function sendCodeToParent(html) {
        parent.postMessage({
            token: shinyrecorder.token,
            html: html
        }, "*");
    }

    // ------------------------------------------------------------------------
    // Input processors
    // ------------------------------------------------------------------------
    //
    // Some inputs need massaging from their raw values to something that can
    // be used when calling `app$set_input()`.
    shinyrecorder.inputProcessor = (function() {
        var inputprocessor = {
            processors: {}
        };

        inputprocessor.add = function(type, fun) {
            inputprocessor.processors[type] = fun;
        };

        inputprocessor.apply = function(type, value) {
            if (inputprocessor.processors[type]) {
                return inputprocessor.processors[type](value);
            } else {
                return inputprocessor.processors["default"](value);
            }
        };

        return inputprocessor;
    })();

    shinyrecorder.inputProcessor.add("default", function(value) {
        function fixup(x) {
            if (typeof(x) === "boolean") {
                if (x) return "TRUE";
                else   return "FALSE";

            } else if (typeof(x) === "string") {
                return '"' + escapeString(x) + '"';

            } else if (x instanceof Array) {
                var res = x.map(fixup);
                return 'c(' + res.join(', ') + ')';

            } else {
                return String(x);
            }
        }

        return fixup(value);
    });

    shinyrecorder.inputProcessor.add("shiny.action", function(value) {
        return '"click"';
    });

    // ------------------------------------------------------------------------
    // Initialization
    // ------------------------------------------------------------------------
    function initialize() {
        // Save initial values so we can check for changes.
        for (var name in Shiny.shinyapp.$inputValues) {
            previousInputValues[name] = JSON.stringify(Shiny.shinyapp.$inputValues[name]);
        }
    }
    $(document).on("shiny:connected", initialize);

    // ------------------------------------------------------------------------
    // Utility functions
    // ------------------------------------------------------------------------
    function escapeHTML(str) {
      return str.replace(/&/g, "&amp;")
                .replace(/</g, "&lt;")
                .replace(/>/g, "&gt;")
                .replace(/"/g, "&quot;")
                .replace(/'/g, "&#039;")
                .replace(/\//g,"&#x2F;");
    }

    function escapeString(str) {
        return str.replace(/"/g, '\\"');
    }

    return shinyrecorder;
})();
