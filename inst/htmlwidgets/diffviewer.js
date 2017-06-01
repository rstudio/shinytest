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

  var MAX_IMAGE_WIDTH = 600;

  var ZOOM_STEPS = [0.25, 0.5, 1, 2];
  var START_ZOOM_IDX = 1;

  // If one of the files was an empty string, then it was likely a missing
  // file. For image diff to work, we need to use an image. This is a 1x1
  // PNG.
  var empty_png = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABAQMAAAAl21bKAAAAA1BMVEUAAACnej3aAAAAAXRSTlMAQObYZgAAAApJREFUCNdjYAAAAAIAAeIhvDMAAAAASUVORK5CYII=";

  diffviewer.init = function(el) {
    var dv = {
      el: el,
      id: el.id
    };

    dv.render = function(message) {
      var $el = $(dv.el);

      if (message.title) {
        $el.append("<h2>" + message.title + "</h2>");
      }
      var $toc = $("<div></div>");
      $el.append($toc);

      var results = message.diff_data.map(function(x, idx) {
        // Append element for current diff
        var diff_el = document.createElement("div");
        diff_el.id  = dv.id + "-file" + idx;
        dv.el.appendChild(diff_el);

        var res;
        if (is_text(x.old) && is_text(x.new)) {
          res = create_text_diff(diff_el, x.filename, x.old, x.new);

        } else if (is_image(x.old) && is_image(x.new)) {
          res = create_image_diff(diff_el, x.filename, x.old, x.new);

        }

        return res;
      });

      render_file_change_table($toc, dv.id, results);

      enable_expand_buttons(dv.el);

    };

    return dv;
  };



  function is_text(str) {
    // If it's not base64 encoded, assume it's text.
    return str === null || !str.match(/^data:[^;]+;base64,/);
  }

  function is_image(str) {
    return str === null || str.match(/^data:image\/[^;]+;base64,/);
  }


  function create_text_diff(el, filename, old_txt, new_txt) {
    var status;
    if (old_txt === new_txt) {
      status = "same";
    } else if (old_txt === null) {
      old_txt = "";
      status = "added";
    } else if (new_txt === null) {
      new_txt = "";
      status = "removed";
    } else {
      status = "changed";
    }

    // Do diff
    var diff_str = JsDiff.createPatch(filename, old_txt, new_txt, "", "");

    // Show diff
    var diff2htmlUi = new Diff2HtmlUI({ diff: diff_str });
    diff2htmlUi.draw("#" + el.id, {
      showFiles: false
    });


    var $el = $(el);
    // Instead of showing a text file icon, we want an expand button.
    $el.find(".d2h-file-name-wrapper .d2h-icon-wrapper")
      .text("")
      .attr("class", "diff-expand-button");

    if (status === "same") {
      // Start with content collapsed
      $el.find(".d2h-file-wrapper").addClass("diffviewer-collapsed");
    }

    // Need to manually modify tags. diff2html adds a CHANGED label even if
    // the file has not changed, so we need to manually make it show NOT
    // CHANGED. Same for ADDED and REMOVED.
    var $status_tag = $el.find(".d2h-tag");

    if (status === "same") {
      $status_tag
        .removeClass("d2h-changed")
        .removeClass("d2h-changed-tag")
        .addClass("d2h-not-changed")
        .addClass("d2h-not-changed-tag")
        .text("NOT CHANGED");

    } else if (status === "added") {
      $status_tag
        .removeClass("d2h-changed")
        .removeClass("d2h-changed-tag")
        .addClass("d2h-added")
        .addClass("d2h-added-tag")
        .text("ADDED");

    } else if (status === "removed") {
      $status_tag
        .removeClass("d2h-changed")
        .removeClass("d2h-changed-tag")
        .addClass("d2h-deleted")
        .addClass("d2h-deleted-tag")
        .text("REMOVED");
    }

    return {
      filename: filename,
      status: status
    };
  }

  function create_image_diff(el, filename, old_img, new_img) {
    var state = {
      filename: filename,
      status: null
    };


    if (old_img === new_img) {
      state.status = "same";
    } else if (old_img === null) {
      old_img = empty_png;
      state.status = "added";
    } else if (new_img === null) {
      new_img = empty_png;
      state.status = "removed";
    } else {
      state.status = "changed";
    }

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


    if (state.status === "same") {
      $wrapper.find(".image-diff-tag")
        .addClass("image-diff-not-changed-tag")
        .text("NOT CHANGED");
      $wrapper.find(".image-diff-container")
        .html('<img class="image-diff-nochange"></img>');
      $wrapper.find(".image-diff-container > img.image-diff-nochange")
        .attr("src", new_img);

      $wrapper.addClass("diffviewer-collapsed");

      return state;
    }

    if (state.status === "changed") {
      $wrapper.find(".image-diff-tag")
        .addClass("image-diff-changed-tag")
        .text("CHANGED");

    } else if (state.status === "added") {
      $wrapper.find(".image-diff-tag")
        .addClass("image-diff-added-tag")
        .text("ADDED");

    } else if (state.status === "removed") {
      $wrapper.find(".image-diff-tag")
        .addClass("image-diff-removed-tag")
        .text("REMOVED");
    }

    $wrapper.find(".image-diff-controls")
      .html(
        '<span class="image-zoom-slider">' +
          '<input type="range" min="0" max="3" value="' + START_ZOOM_IDX + '" step="1">' +
        '</span>' +
        '<span class="image-zoom-text"></span>' +
        '<span class="image-diff-view-buttons">' +
          // TODO: populate these buttons from the views object
          '<span class="image-diff-button image-diff-button-left" data-button="difference">Difference</span>' +
          '<span class="image-diff-button image-diff-button-middle" data-button="toggle">Toggle</span>' +
          '<span class="image-diff-button image-diff-button-right" data-button="slider">Slider</span>' +
        '</span>' +
        '<span class="image-diff-controls-sub"></span>'
      );

    var $container = $wrapper.find(".image-diff-container");
    var $controls = $wrapper.find(".image-diff-controls-sub");
    state.views = Views.create($container, $controls, old_img, new_img);

    // TODO: make zoom work even when there's no difference.
    var $zoom_slider = $wrapper.find('input[type="range"]');
    $zoom_slider.on("input", function(e) {
      state.zoom = ZOOM_STEPS[parseInt(this.value)];
      $wrapper.find(".image-zoom-text").text(state.zoom + "x");

      // Tell the view what the zoom is
      if (state.views && state.views.zoom) {
        state.views.zoom(state.zoom);
      }
    });
    $zoom_slider.trigger("input");


    $wrapper.on("mousedown", ".image-diff-view-buttons > .image-diff-button", function(e) {
      if (e.which !== 1) return;

      var $el = $(this);
      if ($el.hasClass("image-diff-button-selected")) return;

      // Unselect sibling buttons and select this button.
      $el.siblings(".image-diff-button").removeClass("image-diff-button-selected");
      $el.addClass("image-diff-button-selected");

      var button_type = $el.data("button");

      state.views.activate(button_type);
    });

    // Start with first button selected
    $wrapper.find(".image-diff-view-buttons > .image-diff-button:first").trigger({
      type: "mousedown",
      which: 1            // Simulate left button
    });

    return state;
  }


  var Views = (function() {
    var viewTypes = {};

    function create($container, $controls, old_img, new_img) {
      var views = {};

      function activate(name) {
        if (!views[name]) {
          views[name] = viewTypes[name].create($container, $controls, old_img, new_img);
        }

        for (var key in views) {
          if (!views.hasOwnProperty(key))
            continue;

          if (key === name) {
            views[key].show();
          } else {
            views[key].hide();
          }
        }
      }

      return {
        activate: activate
      };
    }

    return {
      viewTypes: viewTypes,
      create: create
    };
  })();


  Views.viewTypes.difference = (function() {
    var view = {
      name: "difference",
      label: "Difference"
    };

    view.create = function($container, $controls, old_img, new_img) {
      var images_ready = false;
      var images_ready_callback;

      var $wrapper = $(
        '<div class="image-difference"><img></img></div>'
      );
      $container.append($wrapper);

      var $img = $wrapper.find("img").on("dragstart", function() { return false; });

      resemble.outputSettings({
        errorColor: {
          red: 200,
          green: 0,
          blue: 0
        },
        transparency: 0.2
      });


      resemble(old_img).compareTo(new_img)
        .onComplete(function(data) {

          $img.attr("src", data.getImageDataUrl());

          images_ready = true;
          if (typeof images_ready_callback === "function") {
            images_ready_callback();
          }
        });


      return {
        $el: $wrapper,
        show: function() { $wrapper.show(); },
        hide: function() { $wrapper.hide(); },
        zoom: function(zoom) {
          // TODO: Implement zoom
          console.log(zoom);
        }
      };
    };

    return view;
  })();


  Views.viewTypes.toggle = (function() {
    var view = {
      name: "toggle",
      label: "Toggle"
    };

    view.create = function($container, $controls, old_img, new_img) {
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

      // Add controls
      var $subcontrols = $(
        '<span>' +
          '<span class="image-diff-button image-diff-button-left image-toggle-button-old">Old</span>' +
          '<span class="image-diff-button image-diff-button-right image-toggle-button-new">New</span>' +
          '<span class="image-diff-button image-toggle-play-button"></span>' +
          '<span class="image-toggle-delay-slider">' +
            '<input type="range" min="0.25" max="2" value="1" step="0.25">' +
          '</span>' +
          '<span class="image-toggle-delay-text"></span>' +
        '</span>'
      );

      $controls.append($subcontrols);

      var $new_div = $wrapper.find(".image-toggle-new");
      var $old_div = $wrapper.find(".image-toggle-old");

      schedule_image_resize_when_loaded(
        $old_div,
        $new_div,
        MAX_IMAGE_WIDTH,
        function() {
          // Attach the wrapper to the DOM only after the images are loaded. This
          // prevents an annoying resize flash, which shows the images after they
          // are loaded but before they are properly resized. The drawback is that
          // there can be a quick blank-out flash.
          $container.append($wrapper);
        }
      );


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

        $new_div.show();
        new_visible = true;
      }

      function hide_new() {
        $old_button.addClass("image-diff-button-selected");
        $new_button.removeClass("image-diff-button-selected");

        $new_div.hide();
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
          schedule_toggle();
        }
      });

      function clear_play_button() {
        $play_button.removeClass("image-toggle-play-button-pause");
        unschedule_toggle();
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
      function schedule_toggle() {
        toggle_timer = setTimeout(function() {
          // If image diff has been removed from DOM, exit so we don't reschedule.
          if ($wrapper.closest(document.documentElement).length === 0)
            return;

          if ($play_button.hasClass("image-toggle-play-button-pause")) {
            toggle_new_visible();
            schedule_toggle();
          }
        }, delay * 1000);
      }
      function unschedule_toggle() {
        clearTimeout(toggle_timer);
      }

      // Start with Old visible
      hide_new();

      $delay_slider.trigger("input");
      $play_button.trigger({
        type: "mousedown",
        which: 1            // Simulate left button
      });


      // State of play button when hidden. Need to know this so that when we
      // show it again, we have the same state.
      var prev_play_state = false;

      return {
        $el: $wrapper,

        show: function() {
          if (prev_play_state) {
            schedule_toggle();
          }
          $wrapper.show();
          $subcontrols.show();
        },

        hide: function() {
          prev_play_state = $play_button.hasClass("image-toggle-play-button-pause");
          if (prev_play_state) {
            unschedule_toggle();
          }
          $wrapper.hide();
          $subcontrols.hide();
        },
        zoom: function(zoom) {
          console.log("implement zoom");
        }
      };
    };

    return view;
  })();


  Views.viewTypes.slider = (function() {
    var view = {
      name: "slider",
      label: "Slider"
    };

    view.create = function($container, $controls, old_img, new_img) {
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

      var $left_div  = $wrapper.find(".image-slider-left");
      var $right_div = $wrapper.find(".image-slider-right");

      schedule_image_resize_when_loaded(
        $left_div,
        $right_div,
        MAX_IMAGE_WIDTH,
        function() {
          // Put the line in the middle.
          $left_div.css("width", "50%");
          // Attach the wrapper to the DOM only after the images are loaded. This
          // prevents an annoying resize flash, which shows the images after they
          // are loaded but before they are properly resized. The drawback is that
          // there can be a quick blank-out flash.
          $container.append($wrapper);
        }
      );

      var $left_label  = $left_div.find(".image-slider-label");
      var $right_label = $right_div.find(".image-slider-label");

      // Add mouse event listener
      $wrapper.on("mousedown", function(e) {
        // Make sure it's the left button
        if (e.which !== 1) return;

        // Find minimum and maximum x values
        var minX = $right_div.offset().left;
        var maxX = minX + Math.max($left_div.outerWidth(), $right_div.outerWidth());

        function slide_to(x) {
          // Constrain mouse position to within image div
          x = Math.max(x, minX);
          x = Math.min(x, maxX);

          // Change width of div
          $left_div.outerWidth(x - $left_div.offset().left);

          // Make labels disappear/reappear as necessary. Use css visibility
          // instead of show()/hide() because the latter will make offset()
          // return 0.
          if (x < $left_label.offset().left + $left_label.width() + 50) {
            $left_label.css("visibility", "hidden");
          } else {
            $left_label.css("visibility", "visible");
          }
          if (x > $right_label.offset().left - 50) {
            $right_label.css("visibility", "hidden");
          } else {
            $right_label.css("visibility", "visible");
          }

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

      return {
        $el: $wrapper,
        show: function() { $wrapper.show(); },
        hide: function() { $wrapper.hide(); },
        zoom: function(zoom) {
          // TODO: Implement zoom
          console.log(zoom);
        }
      };
    };

    return view;
  })();



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

  // Given two divs, each containing an img tag, schedule a scaling of the
  // images after the images are loaded.
  function schedule_image_resize_when_loaded($div1, $div2, max_width, callback) {
    var $img1 = $div1.find("img");
    var $img2 = $div2.find("img");

    // Set the scaling after the images load
    var img1_loaded = false;
    var img2_loaded = false;

    $img1.one("load", function() {
      img1_loaded = true;
      scale_if_all_loaded();
    });
    $img2.one("load", function() {
      img2_loaded = true;
      scale_if_all_loaded();
    });

    function scale_if_all_loaded() {
      if (!(img1_loaded && img2_loaded))
        return;

      scale_image_divs($div1, $div2, max_width);

      if (callback)
        callback();
    }

    function scale_image_divs($div1, $div2, max_width) {
      // Scale images in divs to use same scaling ratio
      var dims = match_image_scaling(
        $div1.find("img"),
        $div2.find("img"),
        max_width
      );

      // Set the dimensions of the divs
      $div1.height(dims.height);
      $div2.height(dims.height);
      $div1.width(dims.width);
      $div2.width(dims.width);
    }

    // Scale two images so that they fit into the same max_width. Returns an
    // object with the width and height of the rectangle that fits both images
    // after being scaled. This can also be used on img elements that are
    // hidden.
    function match_image_scaling($img1, $img2, max_width) {
      var width1 = $img1.prop("naturalWidth");
      var width2 = $img2.prop("naturalWidth");

      var max_natural_width  = Math.max(width1, width2);
      var max_natural_height = Math.max(
        $img1.prop("naturalHeight"),
        $img2.prop("naturalHeight")
      );

      // If images are both smaller than the max width, use 1:1 scaling
      if (max_natural_width <= max_width) {
        $img1.width(width1);
        $img2.width(width2);
        return {
          width: max_natural_width,
          height: max_natural_height
        };
      }

      // If at least one of the images is larger than max_width, find the
      // scaling ratio to fit that image to max_width, and scale both images
      // using that ratio.
      var scale_ratio =  max_width / max_natural_width;
      $img1.width(width1 * scale_ratio);
      $img2.width(width2 * scale_ratio);

      return {
        width: max_width,
        height: max_natural_height * scale_ratio
      };
    }
  }

  function render_file_change_table(el, id, files) {
    var $el = $(el);

    var $list = $('<ul class="diff-file-list"></ul>');
    files.map(function(file, idx) {
      $list.append(
        '<li class="diff-file-' + file.status + '">' +
          '<span class="diff-file-icon"></span>' +
          '<a href = "#' + id + "-file" + idx + '">' +
            file.filename +
          '</a>' +
        '</li>'
      );
    });

    $el.prepend($list);
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
