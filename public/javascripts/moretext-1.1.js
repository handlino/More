(function($) {
    $.moreText = { 
        'version': '1.0',
        'server': 'http://more.handlino.com'
    };

    /**
       $("p").moreText(3)
       $("p").moreText("laihe")
       $("p").moreText(cb)
       $("p").moreText("laihe", cb)
       $("p").moreText(3, cb)
       $("p").moreText(3, "laihe", cb)
     */
    $.fn.moreText = function(n, corpus, cb) {
        var self = this;

        if ($.isFunction(n)) {
            cb = n;
            n = 1;
            corpus = "laihe";
        } else if ( isNaN(parseInt(n)) ) {
            cb = corpus;
            corpus = n;
            n = 1;
        } else {
            n = parseInt(n) || 1;
            if ( typeof(corpus) == "undefined" ) {
                corpus = "laihe";
            } else if ( $.isFunction(corpus) ) {
                cb = corpus;
                corpus = "laihe";
            }
        }

        if (!$.isFunction(cb)) {
            cb = function() { return "default" };
        }

        $.getJSON($.moreText.server + "/sentences.json?callback=?", { 'n': n, 'corpus': corpus }, function(data) {
            cb.call(self, data.sentences);
        });
    };

    $(function() {
        var $lipsums = $("*[class*=lipsum]");

        var n = 0;
        $lipsums.each(function() {
            var m = 1;
            var matched = $(this).attr("class").match(/lipsum\((\d+)\)/);
            if (matched) {
                m = matched[1]
            }
            n += parseInt(m);
        });

        if (n == 0) return;

        var m = location.search.match(/[?&]corpus=([a-z]+)/);
        var corpus = m[1] || "";

        $lipsums.moreText(n, corpus, function(sentences) {
            $lipsums.each(function() {
                var $el = $(this);
                var m = 1;
                var matched = $el.attr("class").match(/lipsum\((\d+)\)/);
                if (matched) {
                    m = matched[1]
                }
                var x = "";
                var i = 0;
                for(i = 0; i < m; i++) { x += sentences.pop(); }
                $el.append( x );
            });
        });
    });
})(jQuery);

