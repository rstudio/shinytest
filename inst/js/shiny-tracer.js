
function shinytest_create_store() {
    if (!window.shinytest) {
	window.shinytest = {
	    connected: true,
	    busy: null,
	    updating: [],
	    log_entries: [],
	    log: function(message) {
		window.shinytest.log_entries.push({
		    timestamp: new Date().toISOString(),
		    message: message
		})
	    }
	};
    }
}

$(document).on("shiny:connected", function(e) {
    shinytest_create_store();
    window.shinytest.log("connected");
});

$(document).on("shiny:busy", function(e) {
    shinytest_create_store();
    window.shinytest.busy = true;
    window.shinytest.log("busy");
});

$(document).on("shiny:idle", function(e) {
    shinytest_create_store();
    window.shinytest.busy = false;
    window.shinytest.log("idle");
});

$(document).on("shiny:value", function(e) {
    shinytest_create_store();
    window.shinytest.log("value " + e.name);

    // Clear up updates
    var idx = window.shinytest.updating.indexOf(e.name);
    if (idx != -1) {
	window.shinytest.updating.splice(idx, 1);
    }
});
