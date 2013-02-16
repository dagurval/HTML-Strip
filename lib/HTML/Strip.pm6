use v6;

grammar HTML::Strip::Grammar {

    token TOP {
        (<comment_start> | <comment_end> | <tag_start> | <tag_quickend> | <tag_end>  | <contents>)+
    }

    token tag_start {
        '<'
    }

    token comment_start {
        '<!--'
    }

    token tag_quickend {
        '/[ ]*>'
    }

    token tag_end {
        '>'
    }

    token comment_end {
        '-->'
    }

    token contents { . }
}

class HTML::Strip::Actions {

    has Str $.out = "";

    has Bool $.emit_space = True;

    has Bool $!inside_comment = False;
    has Bool $!inside_tag = False;
    has Str $!current_tag;

    method tag_start($/) { $!inside_tag = True; }
    method tag_end($/) { 
        $!inside_tag = False; 
        return if not $!out;
        $!out = $!out ~ q{ }
            if $!emit_space and $!out.comb[*-1] ne " ";
    }
    method comment_start($/) { $!inside_comment = True; }
    method comment_end($/) { $!inside_comment = False; }
    method contents($/) { 
        return if $!inside_tag;
        return if $!inside_comment;
        $!out = $!out ~ $/ 
    }

}

my $text = q{<html><body>superstuff</body><!-- some comment <a href="and a 
    link inside comment"></a>--> <a href="http://example.com">example</a>yup</html>};

my $a = HTML::Strip::Actions.new;
HTML::Strip::Grammar.parse($text, :actions($a));
say $a.out();
