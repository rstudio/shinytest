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
          create_text_diff(diff_el, x.filename, x.old, x.new);

        } else if (is_image(x.old) && is_image(x.new)) {
          create_image_diff(diff_el, x.filename, x.old, x.new);

        } else {

        }
      });

      enable_expand_buttons(dv.el);

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


  function create_text_diff(el, filename, old_txt, new_txt) {
    // Do diff
    var diff_str = JsDiff.createPatch(filename, old_txt, new_txt, "", "");

    // Show diff
    var diff2htmlUi = new Diff2HtmlUI({ diff: diff_str });
    diff2htmlUi.draw("#" + el.id, {
      showFiles: false
    });


    var $el = $(el);

    // Instead of showing a text file icon, we want an expand button.
    var $expand_button = $el.find(".d2h-file-name-wrapper .d2h-icon-wrapper")
      .text("")
      .attr("class", "diff-expand-button");

    if (old_txt === new_txt) {
      // Start with content collapsed
      $el.find(".d2h-file-wrapper").addClass("diffviewer-collapsed");

      // diff2html adds a CHANGED label even if the file has not changed,
      // so we need to manually make it show NOT CHANGED.
      $el.find(".d2h-tag")
        .addClass("d2h-not-changed-tag")
        .text("NOT CHANGED");
    }
  }

  function create_image_diff(el, filename, old_img, new_img) {

    var $wrapper = $(
      '<div class="image-diff">' +
        '<div class="image-diff-header">' +
          '<span class="diff-expand-button"></span>' +
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


    if (old_img === new_img) {
      $wrapper.find(".image-diff-tag")
        .addClass("image-diff-not-changed-tag")
        .text("NOT CHANGED");
      $wrapper.find(".image-diff-container")
        .html('<img class="image-diff-nochange"></img>');
      $wrapper.find(".image-diff-container > img.image-diff-nochange")
        .attr("src", new_img);

      $wrapper.addClass("diffviewer-collapsed");

      return;
    }

    $wrapper.find(".image-diff-tag")
      .addClass("image-diff-changed-tag")
      .text("CHANGED");
    $wrapper.find(".image-diff-controls")
      .html(
        '<span class="image-diff-button image-diff-button-left" data-button="difference">Difference</span>' +
        '<span class="image-diff-button image-diff-button-middle" data-button="toggle">Toggle</span>' +
        '<span class="image-diff-button image-diff-button-right" data-button="slider">Slider</span>' +
        '<span class="image-diff-controls-sub"></span>'
      );

    $wrapper.on("mousedown", ".image-diff-controls > .image-diff-button", function(e) {
      if (e.which !== 1) return;

      var $el = $(this);
      if ($el.hasClass("image-diff-button-selected")) return;

      var $container = $wrapper.find(".image-diff-container");

      // Mark button as selected
      $wrapper.find(".image-diff-button").removeClass("image-diff-button-selected");
      $el.addClass("image-diff-button-selected");

      // Clear out sub-controls
      var $controls = $wrapper.find(".image-diff-controls-sub");
      $controls.empty();

      // To prevent document reflow after we remove the image (but before we
      // add it back), we'll fix the height in place here, and then un-fix it
      // after the new image has been added. The reflow can cause the whole
      // page to scroll up, which can be jarring.
      $container.height($container.height());

      $container.empty();

      var button_type = $el.data("button");
      if (button_type == "slider") {
        create_image_slider($container, old_img, new_img);

      } else if (button_type == "difference") {
        create_image_difference($container, old_img, new_img);

      } else if (button_type == "toggle") {
        create_image_toggle($container, old_img, new_img, $controls);
      }

      // The image loading may take some time, so we don't want to release the
      // fixed height until the image has loaded. The selector is a little
      // crude -- we find any image in the container, and then bind this
      // callback to it.
      $container.find("img").one("load", function() {
        $container.css("height", "");
      });
    });

    // Start with difference selected
    $wrapper.find('span[data-button="difference"]').trigger({
      type: "mousedown",
      which: 1            // Simulate left button
    });
  }


  function create_image_difference(el, old_img, new_img) {
    var $el = $(el);
    var $wrapper = $(
      '<div class="image-difference">' +
        '<img></img>' +
      '</div>'
    );
    resemble.outputSettings({
      errorColor: {
        red: 200,
        green: 0,
        blue: 0
      },
      transparency: 0.2
    });

    function set_image_difference_from_cache() {
      $wrapper.children("img")
        .attr("src", $el.data("image-difference-cache"))
        .on("dragstart", function () { return false; });
    }

    if ($el.data("image-difference-cache") === undefined) {
      resemble(old_img).compareTo(new_img)
        .onComplete(function(data) {
          $el.data("image-difference-cache", data.getImageDataUrl());
          set_image_difference_from_cache();
        });

    } else {
      set_image_difference_from_cache();
    }

    $el.append($wrapper);
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

  function create_image_toggle(el, old_img, new_img, $controls) {
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
    $controls.append(
      '<span class="image-diff-button image-diff-button-left image-toggle-button-old">Old</span>' +
      '<span class="image-diff-button image-diff-button-right image-toggle-button-new">New</span>' +
      '<span class="image-diff-button image-toggle-play-button"></span>' +
      '<span class="image-toggle-delay-slider">' +
        '<input type="range" min="0.25" max="2" value="0.75" step="0.25">' +
      '</span>' +
      '<span class="image-toggle-delay-text"></span>'
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
      $new_button.addClass("image-diff-button-selected");
      $old_button.removeClass("image-diff-button-selected");

      $new_image.show();
      new_visible = true;
    }

    function hide_new() {
      $old_button.addClass("image-diff-button-selected");
      $new_button.removeClass("image-diff-button-selected");

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


    var $play_button = $controls.find(".image-toggle-play-button");
    $play_button.on("mousedown", function(e) {
      // Make sure it's the left button
      if (e.which !== 1) return;

      if ($play_button.hasClass("image-toggle-play-button-pause")) {
        // If it's a pause symbol
        clear_play_button();
      } else {
        $play_button.addClass("image-toggle-play-button-pause");
        toggle_and_schedule_toggle();
      }
    });

    function clear_play_button() {
      $play_button.removeClass("image-toggle-play-button-pause");
      clearTimeout(toggle_timer);
    }


    var $delay_slider = $controls.find('input[type="range"]');
    var delay;
    $delay_slider.on("input", function(e) {
      delay = parseFloat(this.value);
      $controls.find(".image-toggle-delay-text").text(delay + " s");
    });


    // Toggle visibility of new image, and schedule the same function to run
    // again after delay, if play button is selected.
    var toggle_timer;
    function toggle_and_schedule_toggle() {
      // If image diff has been removed from DOM, exit so we don't reschedule.
      if ($wrapper.closest(document.documentElement).length === 0)
        return;

      toggle_new_visible();

      toggle_timer = setTimeout(function() {
        if ($play_button.hasClass("image-toggle-play-button-pause")) {
          toggle_and_schedule_toggle();
        }
      }, delay * 1000);
    }


    show_new();
    $delay_slider.trigger("input");
    $play_button.trigger({
      type: "mousedown",
      which: 1            // Simulate left button
    });
  }


  function enable_expand_buttons(el) {
    $(el).on("mousedown", ".diff-expand-button", function(e) {
      if (e.which !== 1) return;

      var $button = $(this);

      // Search for closest text diff or image diff wrapper.
      var $wrapper = $button.closest(".d2h-file-wrapper,.image-diff");

      if ($wrapper.hasClass("diffviewer-collapsed")) {
        $wrapper.removeClass("diffviewer-collapsed");
      } else {
        $wrapper.addClass("diffviewer-collapsed");
      }
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
