#!perl

use warnings;
use strict;

use Test::More qw( no_plan );

BEGIN { use_ok('HTML::TagCloud') };

test_add_categorized_tag();
test_add_uncategorized_tag();
test_add_categorized_and_uncategorized_tags();

exit;

##########################################################################
# Usage      : test_add_categorized_tag();
#
# Purpose    : Verifies that we can insert a categorized tag.
#
# Returns    : Nothing.
#
# Parameters : None.
#
# Throws     : No exceptions.
sub test_add_categorized_tag {
    my $cloud = HTML::TagCloud->new();
    $cloud->add( 'foo', 'http://www.foo.com', 27, 'bar' );
    my @tags = $cloud->tags();
    is( scalar @tags, 1, 'has the expected number of tags' );
    is( $tags[0]->{category}, 'bar', 'has the expected category' );
}

##########################################################################
# Usage      : test_add_uncategorized_tag();
#
# Purpose    : Verifies that we can insert an uncategorized tag.
#
# Returns    : Nothing.
#
# Parameters : None.
#
# Throws     : No exceptions.
sub test_add_uncategorized_tag {
    my $cloud = HTML::TagCloud->new();
    $cloud->add( 'foo', 'http://www.foo.com', 27 );
    my @tags = $cloud->tags();
    is( scalar @tags, 1, 'has the expected number of tags' );
    ok( !defined $tags[0]->{category}, 'has an undefined category' );
}

##########################################################################
# Usage      : test_add_categorized_and_uncategorized_tags();
#
# Purpose    : Verifies that we can insert both categorized and
#              uncategorized tags.
#
# Returns    : Nothing.
#
# Parameters : None.
#
# Throws     : No exceptions.
sub test_add_categorized_and_uncategorized_tags {
    my $cloud = HTML::TagCloud->new();
    $cloud->add( 'foo', 'http://www.foo.com', 27, 'bar' );
    $cloud->add( 'baz', 'http://www.baz.com', 32 );
    my @tags = sort { $a->{name} cmp $b->{name} } $cloud->tags();
    is( scalar @tags, 2, 'has the expected number of tags' );
    ok( !defined $tags[0]->{category}, 'has an undefined category' );
    is( $tags[1]->{category}, 'bar', 'has the correct category' );
}

