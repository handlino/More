#!/usr/bin/env perl
use common::sense;
use Net::Twitter;
use Encode::HanConvert qw(simp_to_trad);
use YAML;

sub grab_tweets {
    my ($keyword, $since_id) = @_;
    my $t = Net::Twitter->new(traits => ['API::Search']);
    my $r;
    my @tweets;

    for (1..10) {
        $r = $t->search({ q => $keyword, page => 11 - $_, since_id => $since_id });
        last unless @{$r->{results}};

        push @tweets, map { simp_to_trad($_) } grep { !/(http|@\S+)/ } map { s{\s+http://plurk.com/p/.+$}{}; $_ } map { $_->{text} } @{$r->{results}};
    }

    return {
        max_id => $r->{max_id},
        tweets => \@tweets
    }
}

my $config_file = "logs/tweets.yml";
my $config = -f $config_file ? YAML::LoadFile($config_file) : [{ q => "不賴" }];


open CORPUS, ">>", "corpus/tweets.txt";
for my $c (@$config) {
    my $r = grab_tweets($c->{q}, $c->{since_id});
    $c->{since_id} = $r->{max_id};
    say CORPUS $_ for @{$r->{tweets}};
}
close CORPUS;

YAML::DumpFile($config_file, $config);

