package More;
use Dancer;
use JSON qw(to_json);
use Acme::Lingua::ZH::Remix;
use Encode qw(encode_utf8);

get '/' => sub {
    template 'index';
};

get '/api' => sub {
    template 'api';
};

get '/sentences.json' => sub {
    my $self = shift;
    my $n = params->{n} || 1;
    my $cb = params->{callback};

    $n = 1 if $n > 100;

    my @sentences;

    push(@sentences, rand_sentence) while($n-->0);

    my $json_text = to_json({ sentences => \@sentences });

    return encode_utf8( $cb ? "${cb}(${json_text})" : $json_text );
};

true;
