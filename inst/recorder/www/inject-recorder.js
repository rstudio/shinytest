window.recorder = (function() {
    var recorder = {
        token: randomId(),
        inputEvents: [],
        testEndpointUrl: null
    };


    // Code injection
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
                "if (Shiny && Shiny.shinyapp && Shiny.shinyapp.config) {" +
                    "var message = {" +
                        "token: '" + recorder.token + "', " +
                        "frameReady: true, " +
                        "testEndpointUrl: Shiny.shinyapp.getTestEndpointUrl({" +
                            "fullUrl:true, inputs:false, outputs:true, exports:true, format:'rds'" +
                        "})" +
                    "};\n" +
                    "parent.postMessage(message, '*');" +
                "}"
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
                evalCodeInFrame("window.shinyRecorder.token = '" + recorder.token + "';");
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
            if (message.token !== recorder.token)
                return;

            var html;

            if (message.frameReady) {
                console.log("Frame is ready.");
                status.frameReady = true;
            }
            if (message.testEndpointUrl) {
                console.log("Test endpoint url: " + message.testEndpointUrl);
                recorder.testEndpointUrl = message.testEndpointUrl;
                Shiny.onInputChange("testEndpointUrl", recorder.testEndpointUrl);
            }
            if (message.inputEvent) {
                var evt = message.inputEvent;

                recorder.inputEvents.push({
                    type: event.inputType,
                    name: event.name,
                    value: event.value
                });

                // Generate R code to display in window
                var value = recorder.inputProcessor.apply(evt.inputType, evt.value);
                html = "app$set_input(" +
                    escapeHTML(message.inputEvent.name) + " = " +
                    escapeHTML(value) +
                    ")\n";
                 $("#shiny-recorder .shiny-recorder-code pre").append(html);
            }

            if (message.outputValue) {
                html = "output: " + message.outputValue.name + ": " + '"' +
                    escapeHTML(escapeString(String(message.outputValue.value))) +
                    '"\n';
                 $("#shiny-recorder .shiny-recorder-code pre").append(html);
            }

            (function() { eval(message.code); }).call(status);
        });

    });


    // ------------------------------------------------------------------------
    // Input processors
    // ------------------------------------------------------------------------
    //
    // Some inputs need massaging from their raw values to something that can
    // be used when calling `app$set_input()`.
    recorder.inputProcessor = (function() {
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

        function processDefault(value) {
            if (typeof(value) === "boolean") {
                if (value) return "TRUE";
                else   return "FALSE";

            } else if (typeof(value) === "string") {
                return '"' + escapeString(value) + '"';

            } else if (value instanceof Array) {
                var res = value.map(processDefault);
                return 'c(' + res.join(', ') + ')';

            } else {
                return String(value);
            }
        }

        inputprocessor.add("default", processDefault);

        return inputprocessor;
    })();


    recorder.inputProcessor.add("shiny.action", function(value) {
        return '"click"';
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

    return recorder;
})();
