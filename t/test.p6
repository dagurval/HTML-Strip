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
