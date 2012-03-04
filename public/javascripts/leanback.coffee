modes = ["kitten", "dreamy", "lorempixel", "placeholdit" ]

mode = "kitten"

changing = 0

change = ->
    if (changing == 3)
        $("#screen").css("background-image", "url(" + $("#loader img").attr("src") + ")")
        $("#loader img").remove()
        $("#screen p").html( $("#loader p").html() )
        changing = 0

    else if (changing == 0)
        mode = modes[ (1 + modes.indexOf(mode)) % modes.length ]
        changing = 1
        load_text()
        load_background()

    setTimeout change, 3000

load_text = ->
    $("#loader p").moreText { 'n': 1, 'max': 45, 'callback': (sentences) ->
        $(this).html(sentences.join("<br>"))
        changing = changing + 1
    }

load_background = ->
    random_height = Math.round(Math.random() * 460 + 500)
    random_width  = Math.round(Math.random() * 760 + 200)
    grey = ""
    grey = "g" if Math.random() > 0.5

    if mode == "kitten"
        url = "http://placekitten.com/" + grey + "/" + random_width + "/" + random_height

    else if mode == "lorempixel"
        url = "http://lorempixel.com/" + grey + "/" + random_width + "/" + random_height

    else if mode == "placeholdit"
        url = "http://placehold.it/" + random_width + "x" + random_height

    else # "dreamy"
        url = location.protocol + "//" + location.host + "/pictures/" + parseInt(Math.random()*1000000000000).toString(16) + "/" + random_width + "x" + random_height +  ".jpg";

    img = new Image();
    $(img).on "load", ->
        changing = changing + 1
    $("#loader").append(img)
    img.src = url

jQuery ->
    jQuery.moreText.server = location.protocol + "//" + location.host
    change()
