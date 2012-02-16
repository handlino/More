package More;
use Dancer ':syntax';
our $VERSION = '1.0';

use strict;

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
    my $limit = params->{limit} || 1024;
    my $corpus = params->{corpus};
    my $remixer = $corpus ? $remixer{$corpus} : undef;

    my @sentences;
    for(1..$n) {
        unless ($corpus) {
            my @corpus = keys %remixer;
            $remixer = $remixer{ $corpus[int(rand() * @corpus)] };
        }

        my $s = $remixer->random_sentence;
        push @sentences, $s;

        $limit -= length($s);
        last if $limit <= 0;
    }

    my $json_text = decode_utf8+to_json({ sentences => \@sentences });
    return $cb ? "${cb}(${json_text})" : $json_text;
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

use Acme::DreamyImage;
use File::Path qw(make_path);

get '/pictures/:seed/:size.jpg' => sub {
    my $params = shift;
    if (params->{seed} !~ /^[0-9a-f]+$/ || params->{size} !~ /^[1-9][0-9]+x[1-9][0-9]+$/) {
        status 'not_found';
        return "File not found."
    }

    my ($width, $height) = split "x", params->{size};

    if ($width > 960 || $height > 960) {
        status 'not_found';
        return "File not found."
    }

    my $seed = params->{seed};

    my $file = Dancer::setting("public") . "/pictures/${seed}/${width}x${height}.jpg";
    my $dir  = dirname($file);
    make_path($dir) unless -d $dir;

    Acme::DreamyImage->new(seed => $seed, width => $width, height => $height)->write(file => $file);

    send_file "/pictures/${seed}/${width}x${height}.jpg";
};

true;
