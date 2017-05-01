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
        var diff_str = JsDiff.createPatch(x.filename, x.old, x.new, "", "");

        // Append element for current diff
        var diff_el = document.createElement("div");
        diff_el.id  = dv.id + "-file" + idx;
        dv.el.appendChild(diff_el);

        // Show diff
        var diff2htmlUi = new Diff2HtmlUI({ diff: diff_str });
        diff2htmlUi.draw("#" + diff_el.id, {
          showFiles: false
        });
      });

    };

    return dv;
  };

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
