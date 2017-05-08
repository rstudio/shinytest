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
          console.log("image file: " + x.filename);

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
    var wrapper = document.createElement("div");
    wrapper.className = "image-slider";
    el.appendChild(wrapper);

    var div = document.createElement("div");
    var img1 = document.createElement("img");
    img1.src = old_img;
    div.appendChild(img1);

    var img2 = document.createElement("img");
    img2.src = new_img;
    wrapper.appendChild(img2);

    wrapper.appendChild(div);

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
