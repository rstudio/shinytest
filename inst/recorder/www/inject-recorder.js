window.recorder = (function() {
    var recorder = {
        token: randomId(),
        testEvents: [],
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

            var html, evt;

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
                evt = message.inputEvent;

                // Filter out clientdata items
                if (evt.name.indexOf(".clientdata") === 0)
                    return;

                recorder.testEvents.push({
                    type: "input",
                    inputType: evt.inputType,
                    name: evt.name,
                    value: evt.value
                });

                // Send updated values to server
                Shiny.onInputChange("testevents:shinytest.testevents", recorder.testEvents);
            }

            if (message.fileUpload) {
                evt = message.fileUpload;

                recorder.testEvents.push({
                    type: "fileUpload",
                    name: evt.name,
                    files: evt.files.map(function(file) { return file.name; })
                });

                // Send updated values to server
                Shiny.onInputChange("testevents:shinytest.testevents", recorder.testEvents);
            }

            if (message.outputValue) {
                evt = message.outputValue;

                recorder.testEvents.push({
                    type: "outputValue",
                    name: evt.name,
                    value: evt.value
                });

                // Send updated values to server
                Shiny.onInputChange("testevents:shinytest.testevents", recorder.testEvents);
            }

            (function() { eval(message.code); }).call(status);
        });

        $(document).on("shiny:inputchanged", function(event) {
            if (event.name === "snapshot") {
                recorder.testEvents.push({
                    type: "snapshot",
                    value: event.value
                });

                // Send updated values to server
                Shiny.onInputChange("testevents:shinytest.testevents", recorder.testEvents);
            }
        });


        $(document).on("shiny:fileuploaded", function(event) {
            console.log('event triggered');
            recorder.testEvents.push({
                type: "fileupload",
                name: evt.name,
                filename: evt.files[0]
            });

            // Send updated values to server
            Shiny.onInputChange("testevents:shinytest.testevents", recorder.testEvents);
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

    return recorder;
})();
