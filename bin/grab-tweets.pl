#!/usr/bin/env perl
use common::sense;
use utf8;

use Net::Twitter;
use Encode::HanConvert qw(simp_to_trad);
use Acme::Lingua::ZH::Remix;
use YAML;
use List::MoreUtils qw(uniq);
use HTML::Entities;

sub grab_tweets {
    my ($keyword, $since_id) = @_;
    my $t = Net::Twitter->new(traits => ['API::Search']);
    my $r;
    my @tweets;

    for (1..5) {
        say "  - page $_";

        $r = $t->search({ q => $keyword, page => $_, since_id => $since_id });
        last unless @{$r->{results}};

        push @tweets, grep { $_ } map { join "", Acme::Lingua::ZH::Remix->split_corpus($_) } map { s/!+/！/g; s/\?+/？/g; s/,+/，/g; s{(?<![[:punct:]])$}{。}; $_ } map { decode_entities($_) }  map { simp_to_trad($_) } grep { !/(http|@\S+)/ } map { s{^.+?\s(.+)\s+http://plurk.com/p/.+$}{$1}; $_ } map { $_->{text} } @{$r->{results}};
    }

    @tweets = uniq sort @tweets;
    say "    - $_" for @tweets;
    return {
        max_id => $r->{max_id},
        tweets => \@tweets
    }
}

my $config_file = "logs/tweets.yml";
my $config = -f $config_file ? YAML::LoadFile($config_file) : [{ q => "不賴", since_id => 1 }];

for my $q (@ARGV) {
    utf8::decode($q) unless utf8::is_utf8($q);

    unshift @$config, { q => $q, since_id => 1 }
}

open CORPUS, ">>", "corpus/tweets.txt";
for my $c (@$config) {
    say "Grab Tweets for $c->{q}";

    my $r = grab_tweets($c->{q}, $c->{since_id});
    $c->{since_id} = $r->{max_id};
    say CORPUS $_ for @{$r->{tweets}};
}
close CORPUS;

YAML::DumpFile($config_file, $config);
