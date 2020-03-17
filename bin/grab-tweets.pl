#!/usr/bin/env perl
use v5.14;
use strict;
use warnings;
use utf8;

use Getopt::Long qw(GetOptions);
use Encode::HanConvert qw(simp_to_trad);

use IO::All;
use List::MoreUtils qw(uniq);
use Net::Twitter;
use URI;
use XML::Feed;
use YAML;

my %opts;
GetOptions(
    \%opts,
    "config|c=s",
) or die("Unrecognised CLI options.");

($opts{config} && -f $opts{config}) or die "Need a config file";

my $config = YAML::LoadFile($opts{config}) or die "Failed to read the configuration file\n";

my @dirs = io->catfile(__FILE__)->absolute->splitdir();
splice @dirs, -2;

my $app_root = io->catdir(@dirs);

sub grab_tweets {
    my ($keyword) = @_;
    my $t = Net::Twitter->new(
        traits => ['API::RESTv1_1'],
        consumer_key        => $config->{consumer_key},
        consumer_secret     => $config->{consumer_secret},
        access_token        => $config->{access_token},
        access_token_secret => $config->{access_token_secret},
    );
    my $r;
    my @tweets;

    $r = $t->search( $keyword );
    push @tweets, grep {
        !/(http|@\S+)/
    } map {
        $_->{text}
    } @{$r->{statuses}};

    @tweets = uniq sort @tweets;

    return @tweets;
}

my @new_tweets;

my @query = qw(咖啡 不賴);

for my $q (@ARGV) {
    utf8::decode($q) unless utf8::is_utf8($q);
    unshift @query, $q;
}

for my $q (@query) {
    push @new_tweets, grab_tweets($q);
}

my @old_tweets = $app_root->catfile("corpus", "tweets.txt")->assert->utf8->chomp->getlines;

my @tweets = sort { length($b) <=> length($a) } map {
    s/!+/！/g;
    s/\?+/？/g;
    s/,+/，/g;
    $_
} grep {
    /\p{Han}{2}/ && /\p{Punct}/ && length($_) > 6
} map {
    split /\r?\n+/
} uniq @new_tweets, @old_tweets;

my $out = $app_root->catfile("corpus", "tweets.txt")->utf8;
$out->println($_) for @tweets;
