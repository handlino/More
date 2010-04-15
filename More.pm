package More;
use Dancer;
use JSON qw(to_json);
use Acme::Lingua::ZH::Remix;

get '/' => sub {
    template 'index';
};

get '/sentences.json' => sub {
    my $self = shift;
    my $n = params->{n} || 1;
    my $cb = params->{callback};

    my @sentences;

    push(@sentences, rand_sentence) while($n-->0);

    my $json_text = to_json({ sentences => \@sentences });

    return $cb ? "${cb}(${json_text})" : $json_text;
};

true;
