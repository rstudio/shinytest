
$(document).on("shiny:connected", function(e) {
    window.shinytest = {
	connected = true,
	log: []
    };
})
