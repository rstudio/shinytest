window.recorder = (function() {
    var token = randomId();

    $(document).ready(function() {
        function evalCodeInFrame(code) {
            var message = {
                token: "abcdef",
                code: code
            };
            $('#app-iframe')[0].contentWindow.postMessage(message, "*");
        }


        // Check that the frame is ready with its Shiny app
        var frameReadyChecker = window.setInterval(function() {
            if (status.frameReady) {
                injectRecorderJS();
                clearTimeout(frameReadyChecker);
                return;
            }

            console.log("Checking if frame is ready");

            // Find out when iframe app is ready - this tells it to send back
            // a message indicating that it's ready.
            evalCodeInFrame(
                "var message = {" +
                    "token: '" + token + "', " +
                    "frameReady: true" +
                "};\n" +
                "parent.postMessage(message, '*');"
            );
        }, 100);


        // Check that the parent frame has the output value with the
        // Javascript code.
        var recoderCodeReadyChecker = window.setInterval(function() {
            console.log("Checking if JS code is ready to be injected...");

            if (Shiny && Shiny.shinyapp && Shiny.shinyapp.$values &&
                Shiny.shinyapp.$values.recorder_js)
            {
                console.log("JS code is ready to be injected.");
                status.recorderCodeReady = true;
                clearTimeout(recoderCodeReadyChecker);
                injectRecorderJS();
            }
        }, 100);


        // Inject recorder code into iframe, but only if hasn't already been done.
        function injectRecorderJS() {
            if (!status.codeHasBeenInjected &&
                status.frameReady &&
                status.recorderCodeReady)
            {
                console.log("Injecting JS code.");
                evalCodeInFrame(Shiny.shinyapp.$values.recorder_js);
                evalCodeInFrame("window.shinyRecorder.token = '" + token + "';");
                status.codeHasBeenInjected = true;
            }
        }


        var status = {
            frameReady: false,
            recorderCodeReady: false,
            codeHasBeenInjected: false
        };


        // Set up message receiver. Code is evaluated with `status` as the
        // context, so that the value can be modified in the right place.
        window.addEventListener("message", function(e) {
            var message = e.data;
            if (message.token !== token)
                return;

            if (message.frameReady) {
                console.log("Frame is ready.");
                status.frameReady = true;
            }
            if (message.inputEvent) {
                var html = "app$set_input(" +
                    escapeHTML(message.inputEvent.name) + " = " +
                    escapeHTML(message.inputEvent.value) +
                    ")\n";
                 $("#shiny-recorder .shiny-recorder-code pre").append(html);
            }
            if (message.html) {
                $("#shiny-recorder .shiny-recorder-code pre").append(message.html);
            }

            (function() { eval(message.code); }).call(status);
        });

    });


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


    function randomId() {
        return Math.floor(0x100000000 + (Math.random() * 0xF00000000)).toString(16);
    }

})();
