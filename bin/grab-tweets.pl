#!/usr/bin/env perl
use common::sense;
use utf8;

# use Acme::Lingua::ZH::Remix;
use Encode::HanConvert qw(simp_to_trad);
use HTML::Entities;
use IO::All;
use List::MoreUtils qw(uniq);
use Net::Twitter;
use URI;
use XML::Feed;
use YAML;

my @dirs = io->catfile(__FILE__)->absolute->splitdir();
splice @dirs, -2;

my $app_root = io->catdir(@dirs);

sub grab_tweets {
    my ($keyword, $since_id) = @_;
    my $t = Net::Twitter->new(traits => ['API::REST', 'API::Search']);
    my $r;
    my @tweets;

    for (1..5) {
        $r = $t->search({ q => $keyword, page => $_, since_id => $since_id });
        last unless @{$r->{results}};

        push @tweets, grep { $_ } map { s/!+/！/g; s/\?+/？/g; s/,+/，/g; s{(?<![[:punct:]])$}{。}; $_ } map { decode_entities($_) }  map { simp_to_trad($_) } grep { !/(http|@\S+)/ } map { s{^.+?\s(.+)\s+http://plurk.com/p/.+$}{$1}; $_ } map { $_->{text} } @{$r->{results}};
    }

    @tweets = uniq sort @tweets;

    return {
        max_id => $r->{max_id},
        tweets => \@tweets
    }
}

my $config_file = $app_root->catfile("logs", "tweets.yml");
my $config = -f $config_file ? YAML::LoadFile($config_file) : [{ q => "不賴", since_id => 1 }, { q => "咖啡", since_id => 1 }];

for my $q (@ARGV) {
    utf8::decode($q) unless utf8::is_utf8($q);

    unshift @$config, { q => $q, since_id => 1 }
}

my @new_tweets;

for my $c (@$config) {
    my $r = grab_tweets($c->{q}, $c->{since_id});
    $c->{since_id} = $r->{max_id};
    push @new_tweets, @{$r->{tweets}};
}

YAML::DumpFile($config_file, $config);

my @old_tweets = $app_root->catfile("corpus", "tweets.txt")->assert->utf8->chomp->getlines;

if (@new_tweets + @old_tweets > 1024) {
    my $n = 1024 - @new_tweets;
    $n = 0 if ($n < 0);
    @old_tweets = @old_tweets[ 0 .. $n ];
}

my @tweets = uniq sort @new_tweets, @old_tweets;

if (@tweets > 1024) {
    my $n = @tweets - 1024;
    @old_tweets = @old_tweets[0..$#old_tweets-$n];
    @tweets = uniq sort @new_tweets, @old_tweets;
}

my $out = $app_root->catfile("corpus", "tweets.txt")->utf8;
$out->println($_) for @tweets;
