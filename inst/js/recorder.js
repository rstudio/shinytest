window.shinyRecorder = (function() {
    var shinyrecorder = {
        inputEvents: []
    };

    $(document).on("shiny:inputchanged", function(event) {
        // Make sure this isn't a duplicate of the last one.
        // See https://github.com/rstudio/shiny/issues/1455
        // TODO: Use more sophisticated dedupe that looks at last entry for
        // this input, not just last element in array.
        if (shinyrecorder.inputEvents.length > 0) {
            var lastEvent = shinyrecorder.inputEvents[shinyrecorder.inputEvents.length - 1];
            if (event.name === lastEvent.name && event.value === lastEvent.value)
                return;
        }

        shinyrecorder.inputEvents.push({
            name: event.name,
            value: event.value
        });

        appendToCode(event.name, event.value);
    });


    function appendToCode(name, value) {
        $("#shiny-recorder .shiny-recorder-code pre")
            .append(escapeHTML(String(name)) + ":" + escapeHTML(String(value)) + "\n");
    }

    function initialize() {
        var panelHtml =
            '<div id="shiny-recorder">' +
                '<div class="shiny-recorder-title">Recorder</div>' +
                '<div class="shiny-recorder-code"><pre></pre></div>' +
            '</div>';
        $("body").append(panelHtml);
        $("#shiny-recorder").css({
            top: "20px",
            right: "20px",
            width: "300px",
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
            background: "#444"
        });
        $("#shiny-recorder .shiny-recorder-code").css({
            "flex-grow": "1",
            "flex-shrink": "1",
            cursor: "text",
            overflow: "auto"
        });


        // Make title bar only draggable
        $("#shiny-recorder").draggable({
            handle: $("#shiny-recorder .shiny-recorder-title")
        });
    }
    $(document).on("shiny:connected", initialize);

    function escapeHTML(str) {
      return str.replace(/&/g, "&amp;")
                .replace(/</g, "&lt;")
                .replace(/>/g, "&gt;")
                .replace(/"/g, "&quot;")
                .replace(/'/g, "&#039;")
                .replace(/\//g,"&#x2F;");
    }

    return shinyrecorder;
})();
