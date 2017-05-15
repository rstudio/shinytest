/*jshint
  undef:true,
  browser:true,
  devel: true,
  jquery:true,
  strict:false,
  curly:false,
  indent:2
*/
/*global diffviewer:true, HTMLWidgets, JsDiff, Diff2HtmlUI, resemble */

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

          // diff2html adds a CHANGED label even if the file has not changed,
          // so we need to manually make it show NOT CHANGED.
          if (x.old === x.new) {
            $(diff_el).find(".d2h-tag")
              .addClass("d2h-not-changed-tag")
              .text("NOT CHANGED");
          }

        } else if (is_image(x.old) && is_image(x.new)) {
          create_image_diff(diff_el, x.filename, x.old, x.new);

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

  function create_image_diff(el, filename, old_img, new_img) {

    var $wrapper = $(
      '<div class="image-diff">' +
        '<div class="image-diff-header">' +
          '<span class="image-diff-expand"></span>' +
          '<span class="image-diff-filename"></span>' +
          '<span class="image-diff-tag"></span>' +
        '</div>' +
        '<div class="image-diff-controls"></div>' +
        '<div class="image-diff-container">' +
          '<div class="image-diff-content">' +
          '</div>' +
        '</div>' +
      '</div>'
    );
    $wrapper.find(".image-diff-filename").text(filename);
    $(el).append($wrapper);

    $wrapper.on("mousedown", ".image-diff-expand", function(e) {
      if (e.which !== 1) return;

      var $el = $(this);
      if ($el.text() === "+") {
        $el.text("\u2013");
        $wrapper.find(".image-diff-controls").show();
        $wrapper.find(".image-diff-container").show();
      } else {
        $el.text("+");
        $wrapper.find(".image-diff-controls").hide();
        $wrapper.find(".image-diff-container").hide();
      }
    });

    if (old_img === new_img) {
      $wrapper.find(".image-diff-tag")
        .addClass("image-diff-not-changed-tag")
        .text("NOT CHANGED");
      $wrapper.find(".image-diff-container")
        .html('<img class="image-diff-nochange"></img>');
      $wrapper.find(".image-diff-container > img.image-diff-nochange")
        .attr("src", new_img);

      $wrapper.find(".image-diff-expand").text("+");
      $wrapper.find(".image-diff-controls").hide();
      $wrapper.find(".image-diff-container").hide();
      return;
    }

    $wrapper.find(".image-diff-tag")
      .addClass("image-diff-changed-tag")
      .text("CHANGED");
    $wrapper.find(".image-diff-expand").html("\u2013");
    $wrapper.find(".image-diff-controls")
      .html(
        '<span class="image-diff-button" data-button="difference">Difference</span>' +
        '<span class="image-diff-button" data-button="toggle">Toggle</span>' +
        '<span class="image-diff-button" data-button="slider">Slider</span>'
      );

    $wrapper.on("mousedown", ".image-diff-button", function(e) {
      if (e.which !== 1) return;

      var $el = $(this);
      if ($el.hasClass("image-diff-button-selected")) return;

      var $container = $wrapper.find(".image-diff-container");

      $wrapper.find(".image-diff-button").removeClass("image-diff-button-selected");
      $el.addClass("image-diff-button-selected");

      $container.empty();

      var button_type = $el.data("button");
      if (button_type == "slider") {
        create_image_slider($container, old_img, new_img);

      } else if (button_type == "difference") {
        create_image_difference($container, old_img, new_img);

      } else if (button_type == "toggle") {
        create_image_toggle($container, old_img, new_img);
      }
    });

    // Start with difference selected
    $wrapper.find('span[data-button="difference"]').trigger({
      type: "mousedown",
      which: 1            // Simulate left button
    });
  }


  var image_difference_cache = null;
  function create_image_difference(el, old_img, new_img) {
    var $wrapper = $(
      '<div class="image-difference">' +
        '<img></img>' +
      '</div>'
    );
    resemble.outputSettings({
      errorColor: {
        red: 255,
        green: 160,
        blue: 127
      },
      transparency: 0.25
    });

    function set_image_difference_from_cache() {
      $wrapper.children("img")
        .attr("src", image_difference_cache)
        .on("dragstart", function () { return false; });
    }

    if (image_difference_cache === null) {
      resemble(old_img).compareTo(new_img)
        .onComplete(function(data) {
          image_difference_cache = data.getImageDataUrl();
          set_image_difference_from_cache();
        });

    } else {
      set_image_difference_from_cache();
    }

    $(el).append($wrapper);
  }


  function create_image_slider(el, old_img, new_img) {
    var $wrapper = $(
      '<div class="image-slider">' +
        '<div class="image-slider-right">' +
          '<img></img>' +
          '<div class="image-slider-label">' +
            '<div class="image-slider-label-text">New</div>' +
          '</div>' +
        '</div>' +
        '<div class="image-slider-left">' +
          '<img></img>' +
          '<div class="image-slider-label">' +
            '<div class="image-slider-label-text">Old</div>' +
          '</div>' +
        '</div>' +
      '</div>'
    );
    $wrapper.find(".image-slider-right > img")
      .attr("src", new_img)
      .on("dragstart", function () { return false; });
    $wrapper.find(".image-slider-left > img")
      .attr("src", old_img)
      .on("dragstart", function () { return false; });
    $(el).append($wrapper);


    // Add mouse event listener
    var $left_image  = $wrapper.find(".image-slider-left");
    var $right_image = $wrapper.find(".image-slider-right");

    $wrapper.on("mousedown", function(e) {
      // Make sure it's the left button
      if (e.which !== 1) return;

      // Find minimum and maximum x values
      var minX = $right_image.offset().left;
      var maxX = minX + $right_image.outerWidth();

      function slide_to(x) {
        // Constrain mouse position to within image div
        x = Math.max(x, minX);
        x = Math.min(x, maxX);

        // Change width of div
        $left_image.outerWidth(x - $left_image.offset().left);
      }

      slide_to(e.pageX);

      $(window).on("mousemove.image-slider", function(e) {
        var x = e.pageX;
        slide_to(x);
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

  function create_image_toggle(el, old_img, new_img) {
    var $wrapper = $(
      '<div class="image-toggle">' +
        '<div class="image-toggle-old"><img></img></div>' +
        '<div class="image-toggle-new"><img></img></div>' +
      '</div>'
    );
    $wrapper.find(".image-toggle-old > img")
      .attr("src", old_img)
      .on("dragstart", function () { return false; });
    $wrapper.find(".image-toggle-new > img")
      .attr("src", new_img)
      .on("dragstart", function () { return false; });
    $(el).append($wrapper);

    // Add controls
    var $controls = $(el).append(
      '<div class="image-toggle-controls">' +
        '<div>' +
          '<span class="image-toggle-button image-toggle-button-old">Old</span>' +
          '<span class="image-toggle-button image-toggle-button-new">New</span>' +
        '</div>' +
        '<div>' +
          '<span class="image-toggle-button image-play-button">&#9654;</span>' +
          '<input type="range" min="0.25" max="2" value="0.75" step="0.25">' +
          '<span class="image-toggle-delay"></span>' +
        '</div>' +
      '</div>'
    );

    var $new_image = $wrapper.find(".image-toggle-new");

    var $new_button = $controls.find(".image-toggle-button-new");
    var $old_button = $controls.find(".image-toggle-button-old");


    var new_visible = true;
    function toggle_new_visible() {
      if (new_visible) {
        hide_new();
      } else {
        show_new();
      }
    }

    function show_new() {
      $new_button.addClass("image-toggle-button-selected");
      $old_button.removeClass("image-toggle-button-selected");

      $new_image.show();
      new_visible = true;
    }

    function hide_new() {
      $old_button.addClass("image-toggle-button-selected");
      $new_button.removeClass("image-toggle-button-selected");

      $new_image.hide();
      new_visible = false;
    }


    $wrapper.on("mousedown", function(e) {
      if (e.which !== 1) return;
      clear_play_button();
      toggle_new_visible();
    });

    $new_button.on("mousedown", function(e) {
      if (e.which !== 1) return;
      clear_play_button();
      show_new();
    });

    $old_button.on("mousedown", function(e) {
      if (e.which !== 1) return;
      clear_play_button();
      hide_new();
    });


    var $play_button = $controls.find(".image-play-button");
    $play_button.on("mousedown", function(e) {
      // Make sure it's the left button
      if (e.which !== 1) return;

      if ($play_button.hasClass("image-toggle-button-selected")) {
        clear_play_button();
      } else {
        $play_button.addClass("image-toggle-button-selected");
        toggle_and_schedule_toggle();
      }
    });

    function clear_play_button() {
      $play_button.removeClass("image-toggle-button-selected");
      clearTimeout(toggle_timer);
    }


    var $delay_slider = $controls.find('input[type="range"]');
    var delay;
    $delay_slider.on("input", function(e) {
      delay = parseFloat(this.value);
      $controls.find(".image-toggle-delay").text(delay + " s");
    });


    // Toggle visibility of new image, and schedule the same function to run
    // again after delay, if play button is selected.
    var toggle_timer;
    function toggle_and_schedule_toggle() {
      toggle_new_visible();

      toggle_timer = setTimeout(function() {
        if ($play_button.hasClass("image-toggle-button-selected")) {
          toggle_and_schedule_toggle();
        }
      }, delay * 1000);
    }


    show_new();
    $delay_slider.trigger("input");
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
