$.fn.moreText = function(n) {
    var sentences = [];

    if (!n) {
        n = 0;
        this.each(function() {
            var m = 1;
            var matched = $(this).attr("class").match(/lipsum\((\d+)\)/);
            if (matched) {
                m = matched[1]
            }

            n += parseInt(m);
        });
    } 
    else {
        n = this.size() * n;
    }

    var self = this;

    $.getJSON("/sentences.json?callback=?", { 'n': n }, function(data) {
        var sentences = data.sentences;

        self.each(function() {
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
};

$(function() {
    $("*[class*=lipsum]").moreText();
});
