$(function() {
    var t = null;
    var tweet = function() {
        if ($('#tweet span').text()) {
            var status = "長官勉勵我們：" + $('#tweet').text();
            var status_with_url = encodeURIComponent(status + ' / ' + document.title + ' ' + location.href);
            $("a.twitter.tools").attr("href", "http://twitter.com/?status="+status_with_url);
            $("a.plurk.tools").attr("href", "http://www.plurk.com/?status="+status_with_url);
            if (t) {
                clearInterval(t);
                t = null;
            }
        }
    };
    t = setInterval(tweet, 1000);

    $("#reload-tweet").bind("click", function() {
        $("#tweet .lipsum").one("ajaxSuccess", function() {
            tweet();
        });
        $("#tweet .lipsum").empty().moreText();
    }).focus();
});
