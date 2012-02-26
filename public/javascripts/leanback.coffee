change_background = ->
    url = location.host + "/pictures/" + parseInt(Math.random()*1000000000000).toString(16) + "/960x960.jpg";
    img = new Image(url);
    img.onload = ->
        $("body").css("background-image", "url(" + url + ")")
    $("#loader").append(img);

jQuery ->
setTimeout change_background, 10000

