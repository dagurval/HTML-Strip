#!/usr/bin/env perl6

BEGIN { @*INC.unshift: '../lib'; }

use HTML::Strip;
use Test;

my $html = q{<html>simple test</html>};
is strip_html($html), "simple test ", "simple strip";

$html = q{<html>< !-- some comment <a>anchor</a>-->text</html>};
is strip_html($html), "text ", "ignore comment";

$html = q{<html><style>ignore me</style>keep me};
is strip_html($html), "keep me", "basic tag strip";


# Below are tests ported from the Perl5 module HTML::Strip
# http://search.cpan.org/~kilinrax/HTML-Strip-1.06/Strip.pm

ok( strip_html( 'test' ), 'test' );
ok( strip_html( '<em>test</em>' ), 'test' );
ok( strip_html( 'foo<br>bar' ), 'foo bar' );
ok( strip_html( '<p align="center">test</p>' ), 'test' );
ok( strip_html( '<p align="center>test</p>' ), '' );
ok( strip_html( '<foo>bar' ), 'bar' );
ok( strip_html( '</foo>baz' ), ' baz' );
ok( strip_html( '<!-- <p>foo</p> bar -->baz' ), 'baz' );
ok( strip_html( '<img src="foo.gif" alt="a > b">bar' ), 'bar' );
ok( strip_html( '<script>if (a<b && a>c)</script>bar' ), 'bar' );
ok( strip_html( '<# just data #>bar' ), 'bar' );
ok( strip_html( '<script>foo</script>bar' ), 'bar' );

skip "TODO: Decode HTML entities", 4;
ok(strip_html( '&#060;foo&#062;' ), '<foo>' );
ok(strip_html( '&lt;foo&gt;' ), '<foo>' );

# :decode_entities(0);
ok(strip_html('&#060;foo&#062;', :decode_entities(False)), '&#060;foo&#062;' );
ok(strip_html('&lt;foo&gt;', :decode_entities(False)), '&lt;foo&gt;' );


my @s = <foo>;

ok(strip_html( '<script>foo</script>bar', :strip_tags(@s)), 'foo bar' );
ok(strip_html( '<foo>foo</foo>bar', :strip_tags(@s) ), 'bar');
ok(strip_html( '<script>foo</script>bar' ), 'bar' );

@s = <baz quux>;
ok( strip_html( '<baz>fumble</baz>bar<quux>foo</quux>' ), 'bar' );
ok( strip_html( '<baz>fumble<quux/>foo</baz>bar' ), 'bar' );
ok( strip_html( '<foo> </foo> <bar> baz </bar>' ), '   baz ' );
