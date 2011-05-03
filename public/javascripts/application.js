$(function() {
    var t = null;
    var tweet = function() {
        if ($('#tweet span').text()) {
            var status = "長官勉勵我們：" + $('#tweet').text();
            var status_with_url = encodeURIComponent(status + ' / ' + document.title + ' ' + location.href);
            $("a.twitter.tools").attr("href", "https://twitter.com/?status="+status_with_url);
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

    $.getJSON('http://search.twitter.com/search.json?q=moretext&callback=?', function(data) {
        $("#recent-tweets").html(
            $.map(data.results, function(x) { 
                return "<a href=\"http://twitter.com/" + x.from_user + "/status/" + x.id + "\"><li class=\"clearfix\"><img src=\"" + x.profile_image_url + "\"> @" + x.from_user + " " + x.text + "</li></a>"
            }).join("")
        );
    });
});

