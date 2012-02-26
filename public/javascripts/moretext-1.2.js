(function($) {
    $.moreText = { 
        'version': '1.2',
        'server': 'http://more.handlino.com'
    };

    /**
       $("p").moreText(3)
       $("p").moreText("laihe")
       $("p").moreText(cb)
       $("p").moreText("laihe", cb)
       $("p").moreText(3, cb)
       $("p").moreText(3, "laihe", cb)

       $("p").moreText({ n: 3, corpus: "laihe", min: 30, max: 150, callback: cb })
     */
    $.fn.moreText = function(n, corpus, cb) {
        var self = this;
        var options = {};

        if (arguments.length == 1 && typeof(n) == "object") {
            options = n;
            n = options["n"];
            corpus = options["corpus"];
            cb = options["callback"];
        } else if ($.isFunction(n)) {
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
            cb = function(sentences) { 
                $(self).text(sentences.join(""));
            };
        }

        var params = { 'n': n };

        if (options["max"]) {
            params["limit"] = options["max"];
        }

        if (options["min"]) {
            if (!params["limit"]) {
                params["limit"] = parseInt(options["min"]) + 140;
            }
            params["limit"] = options["min"] + "," + params["limit"];
        }

        if (corpus) {
            params["corpus"] = corpus;
        }

        $.getJSON($.moreText.server + "/sentences.json?callback=?", params, function(data) {
            cb.call(self, data.sentences);
        });
    };

    $(function() {
        var m = location.search.match(/[?&]corpus=([a-z]+)/) || [];
        var corpus = m[1];

        var $lipsums = $("*[class*=lipsum]");

        var n = 0;
        $lipsums.each(function() {
            var self = this;
            var matched = $(this).attr("class").match(/lipsum(?:\((\d+)(?:,(\d+)(?:[,-](\d+))?\))?)?/);
            if (!matched[1] || (matched[1] && !matched[2]) ) {
                n += parseInt(matched[1])||1;
            }
            else if ( matched[2] ) {
                var params = { 
                    'n': matched[1],
                    'callback': function(sentences) {
                        $(this).append(sentences.join(""));
                    }
                };

                if (matched[3]) {
                    params["min"] = matched[2];
                    params["max"] = matched[3];
                }
                else {
                    params["max"] = matched[2];
                }
                if (corpus) {
                    params["corpus"] = corpus;
                }

                $(self).moreText(params);
            }
        });

        if (n > 0) {
            var params = {
                'n': n,
                'callback': function(sentences) {
                    $(this).each(function() {
                        var $el = $(this);
                        var matched = $el.attr("class").match(/lipsum(?:\((\d+)\)|(?!\()\b)/);

                        if (matched) {
                            var m = parseInt(matched[1]) || 1;
                            var x = "";
                            var i = 0;
                            for(i = 0; i < m; i++) { x += sentences.pop(); }
                            $el.append( x );
                        }
                    });
                }
            };

            if (corpus) {
                params["corpus"] = corpus;
            }

            $lipsums.moreText(params);
        }
    });
})(jQuery);

