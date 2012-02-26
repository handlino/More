changing = 0

change = ->
    if (changing == 3)
        $("#screen").css("background-image", "url(" + $("#loader img").attr("src") + ")")
        $("#loader img").remove()
        $("#screen p").html( $("#loader p").html() )
        changing = 0

    else if (changing == 0)
        changing = 1
        load_text()
        load_background()

    setTimeout change, 3000

load_text = ->
    $("#loader p").moreText { 'n': 3, 'max': 45, 'callback': (sentences) ->
        $(this).html(sentences.join("<br>"))
        changing = changing + 1
    }

load_background = ->
    url = location.protocol + "//" + location.host + "/pictures/" + parseInt(Math.random()*1000000000000).toString(16) + "/960x960.jpg";
    img = new Image();
    $(img).on "load", ->
        changing = changing + 1
    $("#loader").append(img)
    img.src = url

jQuery ->
    jQuery.moreText.server = location.protocol + "//" + location.host
    change()
