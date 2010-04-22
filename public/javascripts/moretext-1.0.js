(function($) {
    $.moreText = { 
        'version': '1.0',
        'server': 'http://more.handlino.com'
    };

    $.fn.moreText = function(n, cb) {
        var self = this;

        if ($.isFunction(n)) {
            cb = n;
            n = 1;
        }
        n = parseInt(n) || 1;

        if (!$.isFunction(cb)) {
            cb = function(sentences) {
                self.text( sentences.join("") );
            };
        }

        $.getJSON($.moreText.server + "/sentences.json?callback=?", { 'n': n }, function(data) {
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
        $lipsums.moreText(n, function(sentences) {
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

