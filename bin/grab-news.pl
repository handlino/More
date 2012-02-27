#!/usr/bin/env perl
use v5.14;
use utf8;
binmode STDOUT, ":utf8";

use URI;
use XML::Feed;
use IO::All;
use Scalar::Util;
use List::MoreUtils qw(uniq);

sub fetch_news_titles {
    my @titles;

    my $feed = XML::Feed->parse(URI->new('http://news.google.com.tw/news?output=rss'))
        or die XML::Feed->errstr;

    for my $entry ($feed->entries) {
        push @titles, $entry->title =~ s/ - .+?$//r =~ s/[_ ]/，/gr =~ s/$/。/r;
    }

    return @titles;
}

my @old_titles = io("corpus/news.txt")->assert->utf8->chomp->getlines;
my @titles = uniq sort fetch_news_titles(), @old_titles;

my $out = io("corpus/news.txt")->utf8;
$out->println($_) for @titles;
