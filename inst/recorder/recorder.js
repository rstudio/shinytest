// The content of this file gets injected into the Shiny application that is
// in the iframe. This is the application for which interactions are being
// recorded.

window.shinyRecorder = (function() {
    var shinyrecorder = {
        initialized: false,
        token: null        // Gets set by parent frame
    };

    // Store previous values for each input. Use JSON so that we can compare
    // non-primitive objects like arrays.
    var previousInputValues = {};

    // Some inputs are changed from the server (via updateTextInput and
    // similar), but we don't want to record these inputs. This keeps track of
    // inputs that were updated this way.
    var updatedInputs = {};

    // When the client receives output values from the server, it's possible
    // for an html output to contain a Shiny input, with some default value.
    // In that case, we don't want to record the input event, because it's
    // automatic. When this happens, it will trigger a shiny:inputchanged
    // event on the same tick.
    var waitingForInputChange = false;

    $(document).on("shiny:inputchanged", function(event) {
        // If the value has been set via a shiny:updateInput event, ignore it
        // this time.
        if (updatedInputs[event.name]) {
            delete updatedInputs[event.name];
            return;
        }

        // If this input change was triggered by an html output, don't record
        // it.
        if (waitingForInputChange) {
            delete updatedInputs[event.name];
            return;
        }

        // Check if value has changed from last time.
        var valueJSON = JSON.stringify(event.value);
        if (valueJSON === previousInputValues[event.name])
            return;
        previousInputValues[event.name] = valueJSON;

        var hasBinding = !!event.binding;
        sendInputEventToParent(event.inputType, event.name, event.value, hasBinding);
    });

    $(document).on("shiny:filedownload", function(event) {
        sendFileDownloadEventToParent(event.name);
    });

    $(document).on("shiny:value", function(event) {
        // For now, we only care _that_ outputs have changed, but not what
        // they are.
        sendOutputEventToParentDebounced();

        // This is used to detect if any output updates trigger an input
        // change.
        waitingForInputChange = true;
        setTimeout(function() { waitingForInputChange = false; }, 0);
    });

    // Register input updates here and ignore them in the shiny:inputchanged
    // listener.
    $(document).on("shiny:updateinput", function(event) {
        var inputId = event.binding.getId(event.target);
        updatedInputs[inputId] = true;
    });

    // Ctrl-click or Cmd-click (Mac) to record an output value
    $(document).on("click", ".shiny-bound-output", function(e) {
        if (!(e.ctrlKey || e.metaKey))
            return;

        var id = e.target.id;
        var value = Shiny.shinyapp.$values[id];

        sendOutputValueToParent(id, value);
    });


    function debounce(f, delay) {
        var timer = null;
        return function() {
            var context = this;
            var args = arguments;
            clearTimeout(timer);
            timer = setTimeout(function () {
                f.apply(context, args);
            }, delay);
        };
    }

    function sendInputEventToParent(inputType, name, value, hasBinding) {
        parent.postMessage({
            token: shinyrecorder.token,
            inputEvent: {
                inputType: inputType,
                name: name,
                value: value,
                hasBinding: hasBinding
             }
        }, "*");
    }

    function sendFileDownloadEventToParent(name, url) {
        parent.postMessage({
            token: shinyrecorder.token,
            fileDownload: { name: name }
        }, "*");
    }

    function sendOutputEventToParent() {
        parent.postMessage({
            token: shinyrecorder.token,
            outputEvent: {}
        }, "*");
    }

    // If multiple outputs are updated in a single reactive flush, the JS
    // output events will all happen in a single tick. Debouncing for one tick
    // will collapse them into a single call to sendOutputEventToParent().
    var sendOutputEventToParentDebounced = debounce(sendOutputEventToParent, 10);

    function sendOutputValueToParent(name, value) {
        parent.postMessage({
            token: shinyrecorder.token,
            outputValue: { name: name, value: value }
        }, "*");
    }


    // ------------------------------------------------------------------------
    // Initialization
    // ------------------------------------------------------------------------
    function initialize() {
        if (shinyrecorder.initialized)
            return;

        // Save initial values so we can check for changes.
        for (var name in Shiny.shinyapp.$inputValues) {
            if (Shiny.shinyapp.$inputValues.hasOwnProperty("name"))
                previousInputValues[name] = JSON.stringify(Shiny.shinyapp.$inputValues[name]);
        }

        shinyrecorder.initialized = true;
    }
    if (Shiny && Shiny.shinyapp && Shiny.shinyapp.isConnected()) {
        initialize();
    } else {
        $(document).on("shiny:connected", initialize);
    }


    return shinyrecorder;
})();
