window.shinyRecorder = (function() {
    var shinyrecorder = {
        inputEvents: []
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
        appendToCode(
            "app$set_input(" +
            escapeHTML(event.name) + " = " +
            escapeHTML(value) +
            ")\n"
        );
    });


    // Ctrl-click to record an output value
    $(document).on("click", ".shiny-bound-output", function(e) {
        if (!e.ctrlKey)
            return;

        var id = e.target.id;
        var value = Shiny.shinyapp.$values[id];

        appendToCode("output: " + id + ": " +
            escapeHTML('"' + escapeString(String(value))) + '"\n');
    });


    function appendToCode(html) {
        $("#shiny-recorder .shiny-recorder-code pre").append(html);

        var $el = $("#shiny-recorder .shiny-recorder-code");
        $el.scrollTop($el.prop("scrollHeight") - $el.height());
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
        return escapeString('"click"');
    });

    // ------------------------------------------------------------------------
    // Initialization
    // ------------------------------------------------------------------------
    function initialize() {
        // Save initial values so we can check for changes.
        for (var name in Shiny.shinyapp.$inputValues) {
            previousInputValues[name] = JSON.stringify(Shiny.shinyapp.$inputValues[name]);
        }

        var panelHtml =
            '<div id="shiny-recorder">' +
                '<div class="shiny-recorder-title">Test event recorder</div>' +
                '<div class="shiny-recorder-code"><pre></pre></div>' +
            '</div>';
        $("body").append(panelHtml);
        $("#shiny-recorder").css({
            bottom: "20px",
            right: "20px",
            width: "400px",
            height: "200px",
            position: "fixed",
            cursor: "move",
            background: "#eee",
            border: "1px solid #666",
            "border-radius": "4px",
            opacity: "0.85",
            display: "flex",
            "flex-direction": "column",
            "z-index": 2000
        });
        $("#shiny-recorder .shiny-recorder-title").css({
            "font-weight": "bold",
            color: "#fff",
            background: "#8a110f",
            padding: "5px"
        });
        $("#shiny-recorder .shiny-recorder-code").css({
            "flex-grow": "1",
            "flex-shrink": "1",
            cursor: "text",
            overflow: "auto"
        });
        $("#shiny-recorder .shiny-recorder-code pre").css({
            "border": "none",
            "background-color": "inherit",
            "overflow": "visible"
        });


        // Make title bar only draggable
        $("#shiny-recorder").draggable({
            handle: $("#shiny-recorder .shiny-recorder-title")
        });
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
