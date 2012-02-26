(function() {
  var change_background;

  change_background = function() {
    var img, url;
    url = location.host + "/pictures/" + parseInt(Math.random() * 1000000000000).toString(16) + "/960x960.jpg";
    img = new Image(url);
    img.onload = function() {
      return $("body").css("background-image", "url(" + url + ")");
    };
    return $("#loader").append(img);
  };

  jQuery(function() {});

  setTimeout(change_background, 10000);

}).call(this);
