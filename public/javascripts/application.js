$(function() {
    $("*[class*=lipsum]").moreText();

    $("#button\\\:regenerate-text").bind("click", function() {
        $("*[class*=lipsum]").empty().moreText();
        return false;
    })
});