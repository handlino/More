(function() {
  var change, changing, load_background, load_text, mode, modes;

  modes = ["kitten", "picsum", "lorempixel", "placeholdit"];

  mode = "kitten";

  changing = 0;

  change = function() {
    if (changing === 3) {
      $("#screen").css("background-image", "url(" + $("#loader img").attr("src") + ")");
      $("#loader img").remove();
      $("#screen p").html($("#loader p").html());
      changing = 0;
    } else if (changing === 0) {
      mode = modes[(1 + modes.indexOf(mode)) % modes.length];
      changing = 1;
      load_text();
      load_background();
    }
    return setTimeout(change, 3000);
  };

  load_text = function() {
    return $("#loader p").moreText({
      'n': 1,
      'max': 45,
      'callback': function(sentences) {
        $(this).html(sentences.join("<br>"));
        return changing = changing + 1;
      }
    });
  };

  load_background = function() {
    var grey, img, random_height, random_width, url;
    random_height = window.innerHeight || Math.round(Math.random() * 460 + 500);
    random_width = window.innerWidth || Math.round(Math.random() * 760 + 200);
    grey = "";
    if (Math.random() > 0.5) grey = "g";
    if (mode === "kitten") {
      url = "http://placekitten.com/" + grey + "/" + random_width + "/" + random_height;
    } else if (mode === "lorempixel") {
      url = "http://lorempixel.com/" + grey + "/" + random_width + "/" + random_height;
    } else if (mode === "placeholdit") {
      url = "http://placehold.it/" + random_width + "x" + random_height;
    } else if (mode === "picsum") {
      url = "http://picsum.photos/" + random_width + "/" + random_height + "/?random";
    }
    if (url) {
      img = new Image();
      $(img).on("load", function() {
        return changing = changing + 1;
      });
      $("#loader").append(img);
      return img.src = url;
    }
  };

  jQuery(function() {
    jQuery.moreText.server = location.protocol + "//" + location.host;
    return change();
  });

}).call(this);
