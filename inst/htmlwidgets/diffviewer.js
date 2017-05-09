/*jshint
  undef:true,
  browser:true,
  devel: true,
  jquery:true,
  strict:false,
  curly:false,
  indent:2
*/
/*global diffviewer:true, HTMLWidgets, JsDiff, Diff2HtmlUI */

diffviewer = (function() {
  var diffviewer = {};


  diffviewer.init = function(el) {
    var dv = {
      el: el,
      id: el.id
    };

    dv.render = function(message) {
      message.diff_data.map(function(x, idx) {
        // Append element for current diff
        var diff_el = document.createElement("div");
        diff_el.id  = dv.id + "-file" + idx;
        dv.el.appendChild(diff_el);

        if (is_text(x.old) && is_text(x.new)) {
          // Do diff
          var diff_str = JsDiff.createPatch(x.filename, x.old, x.new, "", "");

          // Show diff
          var diff2htmlUi = new Diff2HtmlUI({ diff: diff_str });
          diff2htmlUi.draw("#" + diff_el.id, {
            showFiles: false
          });

        } else if (is_image(x.old) && is_image(x.new)) {
          create_image_diff(diff_el, x.old, x.new);

        } else {

        }
      });

    };

    return dv;
  };



  function is_text(str) {
    // If it's not base64 encoded, assume it's text.
    return !str.match(/^data:[^;]+;base64,/);
  }

  function is_image(str) {
    return str.match(/^data:image\/[^;]+;base64,/);
  }

  function create_image_diff(el, old_img, new_img) {
    var $wrapper = $(
      '<div class="image-slider">' +
        '<div class="image-slider-right"><img></img></div>' +
        '<div class="image-slider-left"><img></img></div>' +
        '<div class="image-slider-handle"></div>' +
      '</div>'
    );
    $wrapper.find(".image-slider-right > img").attr("src", new_img);
    $wrapper.find(".image-slider-left > img").attr("src", old_img);
    $(el).append($wrapper);

    addImageSlider(el);
  }

  function addImageSlider(el) {
    var $el = $(el);
    var $left_image  = $el.find(".image-slider-left");
    var $right_image = $el.find(".image-slider-right");
    var $handle      = $el.find(".image-slider-handle");

    $handle.on("mousedown", function(e) {
      // Make sure it's the left button
      if (e.which !== 1) return;

      var lastX = e.pageX;

      // Find minimum and maximum x values
      var minX = $right_image.offset().left;
      var maxX = minX + $right_image.outerWidth();


      $(window).on("mousemove.image-slider", function(e) {
        var x = e.pageX

        // Constrain mouse position to within image div
        x = Math.max(x, $right_image.offset().left)
        x = Math.min(x, $right_image.offset().left + $right_image.outerWidth())

        var dx = x - lastX;

        // Move handle
        $handle.offset({ left: $handle.offset().left + dx });
        // Change width of div
        $left_image.outerWidth($left_image.outerWidth() + dx);

        lastX = x;
      });

      // Need to bind to window to detect mouseup events outside of browser
       // window.
      $(window).one("mouseup", function(e) {
        // Make sure it's the left button
        if (e.which !== 1) return;

        $(window).off("mousemove.image-slider");
      });

    });

  }


  return diffviewer;
}());



HTMLWidgets.widget({

  name: 'diffviewer',

  type: 'output',

  factory: function(el, width, height) {

    var dv = diffviewer.init(el);
    
    return {
      renderValue: function(x) {
        dv.render(x);
      },
      
      resize: function(width, height) {
      },

      dv: dv
    };
  }
});
