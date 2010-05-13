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

    var m = location.search.match(/[?&]corpus=([a-z]+)/) || [];
    var corpus = m[1] || "";

    $("#reload-tweet").bind("click", function() {
        $("#tweet .lipsum").moreText(corpus, function(sentences) {
            $(this).text(sentences[0]);
            tweet();
        });
    }).focus();
});
