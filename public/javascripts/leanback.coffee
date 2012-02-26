image_loaded = false
text_loaded = false

change = ->
    console.log("change")
    if (text_loaded && image_loaded)
        $("#screen").css("background-image", "url(" + $("#loader img").attr("src") + ")")
        $("#loader img").remove()
        $("#screen p").html( $("#loader p").html() )
        image_loaded = false
        text_loaded = false

    else if (!text_loaded && !image_loaded)
        load_text()
        load_background()

    setTimeout change, 3000

load_text = ->
    $("#loader p").moreText { 'n': 3, 'max': 45, 'callback': (sentences) ->
        $(this).html(sentences.join("<br>"))
        text_loaded = true
    }

load_background = ->
    url = location.protocol + "//" + location.host + "/pictures/" + parseInt(Math.random()*1000000000000).toString(16) + "/960x960.jpg";
    img = new Image();
    $(img).on "load", ->
        image_loaded = true
    $("#loader").append(img)
    img.src = url

jQuery ->
    jQuery.moreText.server = location.protocol + "//" + location.host
    change()

