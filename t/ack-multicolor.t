#!perl

use warnings;
use strict;

use Test::More;
use File::Next ();

use lib 't';
use Util;

if ( $^V lt v5.10.0 ) {
    plan skip_all => 'Test incompatible with versions of perl before v.5.10.0.';
}

plan tests => 11;

prep_environment();

my $blue_on_red_start = "\e[34;41m";
my $bright_red_start  = "\e[91m";
my $match_end         = "\e[0m";

NORMAL_COLOR: {
    my @files = qw( t/text/boy-named-sue.txt );
    my @args = qw( (?<bright_red>called) --color );
    my @results = run_ack( @args, @files );

    is( grep({ /(\Q$bright_red_start\E.*\Q$match_end\E.*){2}/ } @results), 1, 'normal match highlighted' ) or diag(explain(\@results));
}

MATCH_WITH_BACKREF: {
    my @files = qw( t/text/boy-named-sue.txt );
    my @args = qw( (?<blue_on_red>called).*\1 --color );
    my @results = run_ack( @args, @files );

    is( @results, 1, 'backref pattern matches once' );

    ok( grep({ /^[^\e]*\Q$blue_on_red_start\E.*?\Q$match_end\E[^\e]*/ } @results), 'match with backreference - first highlighted' ) or diag(explain(\@results));
}

MULTIPLE_MATCHES: {
    my @files = qw( t/text/freedom-of-choice.txt );
    my @args = qw( \b(?<bright_red>v\w+?m)\b.*\b(?<blue_on_red>c\w+?n)\b --color );
    my @results = run_ack( @args, @files );

    is( @results, 1, 'multiple matches on 1 line' ) or diag(explain(\@results));
    is( $results[0], "A ${bright_red_start}victim${match_end} of ${blue_on_red_start}collision${match_end} on the open sea",
        'multiple matches highlighted' ) or diag(explain(\@results));
}

ADJACENT_CAPTURE_COLORING: {
    my @files = qw( t/text/boy-named-sue.txt );
    my @args = qw( (?<bright_red>cal)(?<blue_on_red>led) --color );
    my @results = run_ack( @args, @files );

    is( @results, 1, 'backref pattern matches once' );
    # the double end + start is kinda weird; this test could probably be
    # more robust
    is( $results[0], "I ${bright_red_start}cal${match_end}${blue_on_red_start}led${match_end} him my pa, and he ${bright_red_start}cal${match_end}${blue_on_red_start}led${match_end} me his son,", 'adjacent capture groups should highlight correctly');
}
