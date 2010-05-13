package More;
use Dancer;
use strict;

use JSON qw(to_json);
use Acme::Lingua::ZH::Remix 0.90;
use Encode qw(encode_utf8 decode_utf8);
use XML::RSS;

get '/' => sub {
    template 'index';
};

get '/api' => sub {
    template 'api';
};

my %remixer = ();

{
    for my $corpus_file (<corpus/*.txt>) {
        open(FH, "<:utf8", $corpus_file);
        local $/ = undef;
        my $text = <FH>;
        close(FH);

        my $remixer = Acme::Lingua::ZH::Remix->new;
        $remixer->feed($text);

        my $name = $corpus_file;
        $name =~ s/\.txt$//;
        $name =~ s/^corpus\///;

        $remixer{$name} = $remixer;
    }
}

get '/sentences.json' => sub {
    my $self = shift;
    my $cb = params->{callback};
    my $n  = params->{n} || 1;
    $n = 1 if $n > 100;
    my $corpus = params->{corpus};
    my $remixer = $corpus ? $remixer{$corpus} : undef;

    if (!$remixer) {
        my @corpus = keys %remixer;
        $remixer = $remixer{ $corpus[int(rand() * @corpus)] };
    }

    my @sentences = map { $remixer->random_sentence } 1..$n;
    my $json_text = to_json({ sentences => \@sentences });
    return encode_utf8( $cb ? "${cb}(${json_text})" : $json_text );
};

get '/sentences.rss' => sub {
    my $self = shift;

    my $rss = XML::RSS->new(version => '1.0', encoding => "utf8");
    $rss->channel(
        title => "MoreText",
        link  => "http://more.handlino.com",
        description => "The Chinese Lipsum generator you love."
    );

    for my $remixer (values %remixer) {
        $rss->add_item(
            title       => $remixer->random_sentence,
            link        => "http://more.handlino.com",
            description => join "", map { $remixer->random_sentence } 1..3,
        );
    }

    return encode_utf8($rss->as_string);
};

true;
