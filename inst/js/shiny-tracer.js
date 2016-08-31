
$(document).on("shiny:connected", function(e) {
    window.shinytest = {
	connected: true,
	log_entries: [],
	log: function(message) {
	    window.shinytest.log_entries.push({
		timestamp: new Date(),
		message: message
	    })
	}
    };
    window.shinytest.log("connected");
})
