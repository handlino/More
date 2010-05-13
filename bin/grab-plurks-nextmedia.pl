#!/usr/bin/env perl
use common::sense;
use WWW::Mechanize;
use HTML::TreeBuilder::Select;
use YAML 'LoadFile';
use Getopt::Std;

my %opts;
getopt('c', \%opts);
die "Usage: $0 -c plurk.yml\n" unless $opts{c};

my $config = LoadFile($opts{c}) or die "Fail to load $opts{c}.yml\n";

my @corpus;

my $mech = WWW::Mechanize->new(autocheck =>0);
$mech->agent_alias( 'Mac Mozilla' );

$mech->get("http://www.plurk.com/m/login");
$mech->submit_form(with_fields => {username => $config->{username}, password => $config->{password}});

$mech->get("http://www.plurk.com/m/u/TW_nextmedia");

for(1..10) {
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
