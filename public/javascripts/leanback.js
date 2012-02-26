(function() {
  var change, image_loaded, load_background, load_text, text_loaded;

  image_loaded = false;

  text_loaded = false;

  change = function() {
    console.log("change");
    if (text_loaded && image_loaded) {
      $("#screen").css("background-image", "url(" + $("#loader img").attr("src") + ")");
      $("#loader img").remove();
      $("#screen p").html($("#loader p").html());
      image_loaded = false;
      text_loaded = false;
    } else if (!text_loaded && !image_loaded) {
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
        return text_loaded = true;
      }
    });
  };

  load_background = function() {
    var img, url;
    url = location.protocol + "//" + location.host + "/pictures/" + parseInt(Math.random() * 1000000000000).toString(16) + "/960x960.jpg";
    img = new Image();
    $(img).on("load", function() {
      return image_loaded = true;
    });
    $("#loader").append(img);
    return img.src = url;
  };

  jQuery(function() {
    jQuery.moreText.server = location.protocol + "//" + location.host;
    return change();
  });

}).call(this);
