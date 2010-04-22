(function($) {
    $.moreText = { 
        'version': '1.0',
        'server': 'http://more.handlino.com'
    };

    $.fn.moreText = function(n, cb) {
        if ($.isFunction(n)) {
            cb = n;
            n = 1;
        }
        n = parseInt(n) || 1;
        
        var self = this;
        $.getJSON($.moreText.server + "/sentences.json?callback=?", { 'n': n }, function(data) {
            var sentences = data.sentences;
            if ($.isFunction(cb)) {
                cb.call(self, sentences)
            }
        });
    };

    $(function() {
        var $lipsums = $("*[class*=lipsum]");

        var n = 1;
        $lipsums.each(function() {
            var m = 1;
            var matched = $(this).attr("class").match(/lipsum\((\d+)\)/);
            if (matched) {
                m = matched[1]
            }
            n += parseInt(m);
        });

        $lipsums.moreText(n, function(sentences) {
            $lipsums.each(function() {
                var $el = $(this);
                var m = 1;
                var matched = $el.attr("class").match(/lipsum\((\d+)\)/);
                if (matched) {
                    m = matched[1]
                }
                var x = "";
                for(var i = 0; i < m; i++) { x += sentences.pop(); }
                $el.append( x );
            });
        });
    });
})(jQuery);

