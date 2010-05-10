package More;
use Dancer;
use strict;

use JSON qw(to_json);
use Acme::Lingua::ZH::Remix 0.90;
use Encode qw(encode_utf8);

get '/' => sub {
    template 'index';
};

get '/api' => sub {
    template 'api';
};

my %remixer = (
    default => Acme::Lingua::ZH::Remix->new
);

get '/sentences.json' => sub {
    my $self = shift;
    my $n = params->{n} || 1;
    my $cb = params->{callback};
    my $corpus = params->{corpus} || "default";

    my $remixer = $remixer{$corpus};
    unless($remixer) {
        my $corpus_file = Dancer::Config::setting("appdir") . "/corpus/${corpus}.txt";
        if (-f $corpus_file) {
            open(FH, "<:utf8", $corpus_file);
            local $/ = undef;
            my $text = <FH>;
            close(FH);

            $remixer{$corpus} = Acme::Lingua::ZH::Remix->new;
            $remixer{$corpus}->feed($text);

            $remixer = $remixer{$corpus};
        }
        else {
            $remixer = $remixer{default};
        }
    }


    $n = 1 if $n > 100;
    my @sentences = map { $remixer->random_sentence } 1..$n;

    my $json_text = to_json({ sentences => \@sentences });

    return encode_utf8( $cb ? "${cb}(${json_text})" : $json_text );
};

true;
