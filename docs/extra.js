$(document).ready(function() {
  function shrinkImage(el, percent) {
    $(el).width(el.naturalWidth * percent);
  };

  // Resize images in the content body by 50%
  // The p selector is there so we don't resize the CI badges on the main page.
  $(".contents p > img").each(function() {
    if (this.complete) {
      shrinkImage(this, 0.5);
    }
    // In case the image isn't already loaded, or if it gets loaded agin in
    // the future.
    $(this).on("load", function() {
      shrinkImage(this, 0.5);
    });
  });
});
