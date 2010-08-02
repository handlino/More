#!/usr/bin/env perl
use common::sense;
use WWW::Mechanize;
use HTML::TreeBuilder::Select;

my @corpus;

my $mech = WWW::Mechanize->new(autocheck =>0);
$mech->agent_alias('Mac Mozilla');

$mech->get("http://www.plurk.com/m/u/TW_nextmedia");

{
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

        my @p = map { join("，", split(" ", $_)) } map { s{(?<![[:punct:]])$}{。}; $_} grep { s/^\s+//g;s/\s+$//g; $_ } grep { !/(tw.*\.nextmedia\.com|\*\*.+\*\*)/ } map { ref($_) ? $_->as_trimmed_text : $_ } @children;
        say "=> $_" for @p;
        push @corpus, @p;
    }

    $mech->follow_link(text_regex => qr/(next|下一頁)/i) or last;
}

open OUT, ">>", "corpus/nextmedia.txt";
binmode(OUT, ":utf8");
say OUT $_ for @corpus;
close OUT;
