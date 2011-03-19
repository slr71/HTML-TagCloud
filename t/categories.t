#!perl

use warnings;
use strict;

use Test::More qw( no_plan );

BEGIN { use_ok('HTML::TagCloud') };

test_add_categorized_tag();
test_add_uncategorized_tag();
test_add_categorized_and_uncategorized_tags();
test_html_for_empty_cloud();
test_html_with_one_categorized_tag();

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
    my $cloud = HTML::TagCloud->new( categories => [qw(bar)] );
    $cloud->add( 'foo', 'http://www.foo.com', 27, 'bar' );
    my @tags = $cloud->tags();
    is( scalar @tags,         1,     'has the expected number of tags' );
    is( $tags[0]->{category}, 'bar', 'has the expected category' );
    return;
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
    my $cloud = HTML::TagCloud->new( categories => [qw(bar)] );
    $cloud->add( 'foo', 'http://www.foo.com', 27 );
    my @tags = $cloud->tags();
    is( scalar @tags, 1, 'has the expected number of tags' );
    ok( !defined $tags[0]->{category}, 'has an undefined category' );
    return;
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
    my $cloud = HTML::TagCloud->new( categories => [qw(bar)] );
    $cloud->add( 'foo', 'http://www.foo.com', 27, 'bar' );
    $cloud->add( 'baz', 'http://www.baz.com', 32 );
    my @tags = sort { $a->{name} cmp $b->{name} } $cloud->tags();
    is( scalar @tags, 2, 'has the expected number of tags' );
    ok( !defined $tags[0]->{category}, 'has an undefined category' );
    is( $tags[1]->{category}, 'bar', 'has the correct category' );
    return;
}

##########################################################################
# Usage      : test_html_for_empty_cloud();
#
# Purpose    : Verifies that the HTML tag cloud with categories is empty
#              when there are no tags in the cloud.
#
# Returns    : Nothing.
#
# Parameters : None.
#
# Throws     : No exceptions.
sub test_html_for_empty_cloud {
    my $cloud = HTML::TagCloud->new( categories => [qw(bar)] );
    is( $cloud->html_with_categories(), q{}, 'empty cloud with categories' );
    return;
}

##########################################################################
# Usage      : test_html_with_one_categorized_tag();
#
# Purpose    : Verifies that the HTML with one categorized tag is correct.
#
# Returns    : Nothing.
#
# Parameters : None.
#
# Throws     : No exceptions.
sub test_html_with_one_categorized_tag {
    my $cloud = HTML::TagCloud->new( categories => [qw(bar)] );
    $cloud->add( 'foo', 'http://www.foo.com', 27, 'bar' );
    my $got = $cloud->html();
    my $expected = expected_html_with_one_categorized_tag();
    #is( $got, $expected, 'one-tag HTML with dependencies' );
    use Data::Dumper;
    warn Dumper $got;
    return;
}

##########################################################################
# Usage      : expected_html_with_one_categorized_tag()
#
# Purpose    : Generates the HTML we expect to get for the test with one
#              categorized tag.
#
# Returns    : The formatted HTML.
#
# Parameters : None.
#
# Throws     : No exceptions.
sub expected_html_with_one_categorized_tag {
    return <<'END_OF_HTML';
END_OF_HTML
}
