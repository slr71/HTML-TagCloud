package HTML::TagCloud;
use strict;
use warnings;
our $VERSION = '0.36';

sub new {
  my $class = shift;
  my $self  = {
    counts                    => {},
    urls                      => {},
    levels                    => 24,
    distinguish_adjacent_tags => 0,
    @_
  };
  bless $self, $class;
  return $self;
}

sub add {
  my($self, $tag, $url, $count) = @_;
  $self->{counts}->{$tag} = $count;
  $self->{urls}->{$tag} = $url;
}

sub add_static {
    my ($self, $tag, $count) = @_;
    $self->{counts}->{$tag} = $count;
}

sub css {
  my ($self) = @_;
  my $css = q(
#htmltagcloud {
  text-align:  center; 
  line-height: 1; 
}
);
  foreach my $level (0 .. $self->{levels}) {
    if ( $self->{distinguish_adjacent_tags} ) {
      $css .= $self->_css_for_tag($level, 'even');
      $css .= $self->_css_for_tag($level, 'odd');
    } else {
      $css .= $self->_css_for_tag($level, q{});
    }
  }
  return $css;
}

sub _css_for_tag {
    my ($self, $level, $subclass) = @_;
    my $font = 12 + $level;
    return <<"END_OF_TAG";
span.tagcloud${level}${subclass} {font-size: ${font}px;}
span.tagcloud${level}${subclass} a {text-decoration: none;}
END_OF_TAG
}

sub tags {
  my($self, $limit) = @_;
  my $counts = $self->{counts};
  my $urls   = $self->{urls}; 
  my @tags = sort { $counts->{$b} <=> $counts->{$a} } keys %$counts;
  @tags = splice(@tags, 0, $limit) if defined $limit;

  return unless scalar @tags;

  my $min = log($counts->{$tags[-1]});
  my $max = log($counts->{$tags[0]});
  my $factor;
  
  # special case all tags having the same count
  if ($max - $min == 0) {
    $min = $min - $self->{levels};
    $factor = 1;
  } else {
    $factor = $self->{levels} / ($max - $min);
  }
  
  if (scalar @tags < $self->{levels} ) {
    $factor *= (scalar @tags/$self->{levels});
  }
  my @tag_items;
  foreach my $tag (sort @tags) {
    my $tag_item;
    $tag_item->{name} = $tag;
    $tag_item->{count} = $counts->{$tag};
    $tag_item->{url}   = $urls->{$tag};
    $tag_item->{level} = int((log($tag_item->{count}) - $min) * $factor);
    push @tag_items,$tag_item;
  }
  return @tag_items;
}

sub html {
  my($self, $limit) = @_;
  my @tags=$self->tags($limit);

  my $ntags = scalar(@tags);
  if ($ntags == 0) {
    return "";
  } elsif ($ntags == 1) {
    my $tag = $tags[0];
    my $span = $self->_format_span(@{$tag}{qw(name url)}, 1, 1);
    return qq{<div id="htmltagcloud">$span</div>\n};
  }

#  warn "min $min - max $max ($factor)";
#  warn(($min - $min) * $factor);
#  warn(($max - $min) * $factor);

  my $html = "";
  my $is_even = 1;
  foreach my $tag (@tags) {
    my $span = $self->_format_span(@{$tag}{qw(name url level)}, $is_even);
    $html .= "$span\n";
    $is_even = !$is_even;
  }
  $html = qq{<div id="htmltagcloud">
$html</div>};
  return $html;
}

sub html_and_css {
  my($self, $limit) = @_;
  my $html = qq{<style type="text/css">\n} . $self->css . "</style>";
  $html .= $self->html($limit);
  return $html;
}

sub _format_span {
  my ($self, $name, $url, $level, $is_even) = @_;
  my $subclass = q{};
  if ( $self->{distinguish_adjacent_tags} ) {
      $subclass = $is_even ? 'even' : 'odd';
  }
  my $span_class = qq{tagcloud$level$subclass};
  my $span = qq{<span class="$span_class">};
  if (defined $url) {
    $span .= qq{<a href="$url">};
  }
  $span .= $name;
  if (defined $url) {
    $span .= qq{</a>};
  }
  $span .= qq{</span>};
}

1;

__END__

=head1 NAME

HTML::TagCloud - Generate An HTML Tag Cloud

=head1 SYNOPSIS

  # A cloud with tags that link to other web pages.
  my $cloud = HTML::TagCloud->new;
  $cloud->add($tag1, $url1, $count1);
  $cloud->add($tag2, $url2, $count2);
  $cloud->add($tag3, $url3, $count3);
  my $html = $cloud->html_and_css(50);

  # A cloud with tags that do not link to other web pages.
  my $cloud = HTML::TagCloud->new;
  $cloud->add_static($tag1, $count1);
  $cloud->add_static($tag2, $count2);
  $cloud->add_static($tag3, $count3);
  
=head1 DESCRIPTION

The L<HTML::TagCloud> module enables you to generate "tag clouds" in
HTML. Tag clouds serve as a textual way to visualize terms and topics
that are used most frequently. The tags are sorted alphabetically and a
larger font is used to indicate more frequent term usage.

Example sites with tag clouds: L<http://www.43things.com/>,
L<http://www.astray.com/recipes/> and
L<http://www.flickr.com/photos/tags/>.

This module provides a simple interface to generating a CSS-based HTML
tag cloud. You simply pass in a set of tags, their URL and their count.
This module outputs stylesheet-based HTML. You may use the included CSS
or use your own.

=head1 CONSTRUCTOR

=head2 new

The constructor takes two optional arguments:

  my $cloud = HTML::TagCloud->new(levels=>10);

if not provided, levels defaults to 24

  my $cloud = HTML::TagCloud->new(distinguish_adjacent_tags=>1);

If distinguish_adjacent_tags is true HTML::TagCloud will use different CSS
classes for adjacent tags in order to be able to make it easier to
distinguish adjacent multi-word tags.  If not specified, this parameter
defaults to a false value.

=head1 METHODS

=head2 add

This module adds a tag into the cloud. You pass in the tag name, its URL
and its count:

  $cloud->add($tag1, $url1, $count1);
  $cloud->add($tag2, $url2, $count2);
  $cloud->add($tag3, $url3, $count3);

=head2 add_static

This module adds a tag that does not link to another web page into the
cloud.  You pass in the tag name and its count:

  $cloud->add_static($tag1, $count1);
  $cloud->add_static($tag2, $count2);

=head2 tags($limit)

Returns a list of hashrefs representing each tag in the cloud, sorted by
alphabet. Each tag has the following keys: name, count, url and level.

=head2 css

This returns the CSS that will format the HTML returned by the html()
method with tags which have a high count as larger:

  my $css  = $cloud->css;

=head2 html($limit)

This returns the tag cloud as HTML without the embedded CSS (you should
use both css() and html() or simply the html_and_css() method). If a
limit is provided, only the top $limit tags are in the cloud, otherwise
all the tags are in the cloud:

  my $html = $cloud->html(200);

=head2 html_and_css($limit)

This returns the tag cloud as HTML with embedded CSS. If a limit is
provided, only the top $limit tags are in the cloud, otherwise all the
tags are in the cloud:

  my $html_and_css = $cloud->html_and_css(50);

=head1 AUTHOR

Leon Brocard, C<< <acme@astray.com> >>.

=head1 COPYRIGHT

Copyright (C) 2005-6, Leon Brocard

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.

