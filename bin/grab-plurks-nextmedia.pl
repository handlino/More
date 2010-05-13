#!/usr/bin/env perl
use common::sense;

# http://www.plurk.com/m/u/TW_nextmedia
use WWW::Mechanize::Cached;
use HTML::TreeBuilder::Select;

my @corpus;

my $mech = WWW::Mechanize::Cached->new;

$mech->get("http://www.plurk.com/m/u/TW_nextmedia");

my $tree = HTML::TreeBuilder::Select->new;
$tree->parse($mech->content);
my @plurks = $tree->select(".plurk");


for (@plurks) {
    my @children = $_->content_list;
    shift @children;
    shift @children;
    pop @children;

    if ($children[0]->tag eq 'span') {
        shift @children;
    }

    push @corpus, map { join("，", split(" ", $_)) } map { s{(?<![[:punct:]])$}{。}; $_} grep { s/^\s+//g;s/\s+$//g; $_ } grep { !/(tw\.img\.nextmedia\.com|\*\*.+\*\*)/ } map { ref($_) ? $_->as_trimmed_text : $_ } @children;
}

$mech->follow_link(url_regex => qr/(?i:offset=\d+$)/);

open OUT, ">>:utf8", "corpus/nextmedia.txt";
say OUT $_ for @corpus;
close OUT;
