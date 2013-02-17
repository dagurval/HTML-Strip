use v6;

grammar HTML::Strip::Grammar {

    token TOP {
        (<comment_start> | <comment_end> 
         | <closing_tag_start> | <tag_start> 
         | <tag_quickend> | <tag_end>  
         | <contents>)+
    }

    token tag_start {
        '<'
    }

    token closing_tag_start {
        '<' \s* '/'
    }

    token comment_start {
        '<' \s* '!' \s* '--'
    }

    token tag_quickend {
        '/' \s* '>'
    }

    token tag_end {
        '>'
    }

    token comment_end {
        '--' \s* '>'
    }

    token contents { . }
}

class HTML::Strip::Actions {

    has Str $.out = "";

    has Bool $.emit_space = True;

    has Bool $!inside_comment = False;
    has Bool $!inside_tag = False;
    
    has Bool $!ignore_contents = False;

    has Str $!curr_tag = "";


    has @.ignore_tags = qw{title script style applet};

    method tag_start($/) { 
        $!inside_tag = True; 
        $!curr_tag = q{};
    }

    method tag_end($/) { 
        $!inside_tag = False; 

        $!ignore_contents = @!ignore_tags ~~ $!curr_tag;

        return if not $!out;
        $!out = $!out ~ q{ }
            if $!emit_space and $!out.comb[*-1] ne " ";
    }
    method tag_quickend($/) {
        $!inside_tag = False;
    }
    method comment_start($/) { 
        #print "<comment start>";
        $!inside_comment = True; 
    }

    method comment_end($/) { 
        #print "<comment end>";
        $!inside_comment = False; 
    }

    method contents($/) { 
        #print $/;
        return if $!inside_comment;

        if $!inside_tag {
            $!curr_tag = $!curr_tag ~ $/;
            return;
        }
        return if $!ignore_contents;
        $!out = $!out ~ $/ 
    }
    
    method closing_tag_start($/) {
        $!ignore_contents = False;
        $!inside_tag = True;
    }

}

constant @DEFAULT_STRIP_TAGS = qw{title script style applet};

sub strip_html(Str $html, :$emit_space, :@ignore_tags) is export {
    my $a = HTML::Strip::Actions.new;
    HTML::Strip::Grammar.parse($html, :actions($a));
    return $a.out();
}

my $text = q{<html><script>ignoreme</script><body>superstuff</body><!-- some comment <a href="and a 
    link inside comment"></a>--> <a href="http://example.com">example</a>yup</html>};

say strip_html($text);
