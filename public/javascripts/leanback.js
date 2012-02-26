(function() {
  var change, changing, load_background, load_text;

  changing = 0;

  change = function() {
    if (changing === 3) {
      $("#screen").css("background-image", "url(" + $("#loader img").attr("src") + ")");
      $("#loader img").remove();
      $("#screen p").html($("#loader p").html());
      changing = 0;
    } else if (changing === 0) {
      changing = 1;
      load_text();
      load_background();
    }
    return setTimeout(change, 3000);
  };

  load_text = function() {
    return $("#loader p").moreText({
      'n': 3,
      'max': 45,
      'callback': function(sentences) {
        $(this).html(sentences.join("<br>"));
        return changing = changing + 1;
      }
    });
  };

  load_background = function() {
    var img, url;
    url = location.protocol + "//" + location.host + "/pictures/" + parseInt(Math.random() * 1000000000000).toString(16) + "/960x960.jpg";
    img = new Image();
    $(img).on("load", function() {
      return changing = changing + 1;
    });
    $("#loader").append(img);
    return img.src = url;
  };

  jQuery(function() {
    jQuery.moreText.server = location.protocol + "//" + location.host;
    return change();
  });

}).call(this);
