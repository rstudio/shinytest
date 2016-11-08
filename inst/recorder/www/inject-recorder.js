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
                "var message = { token: '" + token + "', " +
                "code: 'this.frameReady = true;'" +
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
            var data = e.data;
            if (data.token !== token)
                return;

            (function() { eval(data.code); }).call(status);
        });

    });



    function randomId() {
        return Math.floor(0x100000000 + (Math.random() * 0xF00000000)).toString(16);
    }

})();
