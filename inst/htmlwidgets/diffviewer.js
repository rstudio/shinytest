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
      var diff_str = message.diff_data.map(function(x) {
        return JsDiff.createPatch(x.filename, x.old, x.new, "", "");
      });

      diff_str = diff_str.join("\n");

      var diff2htmlUi = new Diff2HtmlUI({ diff: diff_str });
      diff2htmlUi.draw("#" + dv.id, {
        showFiles: true
        // outputFormat: "side-by-side" 
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
