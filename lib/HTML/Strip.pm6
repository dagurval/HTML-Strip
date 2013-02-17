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
    has Bool $.emit_space is rw;
    has @.strip_tags is rw;

    has Bool $!inside_comment = False;
    has Bool $!ignore_contents = False;

    has Str $!curr_tag = "";
    has Bool $!inside_tag = False;
    has Bool $!is_closing_tag = False;



    method tag_start($/) { 
        $!inside_tag = True; 
        $!curr_tag = q{};
        $!is_closing_tag = False;
    }

    method tag_end($/) { 
        $!inside_tag = False; 

        $!ignore_contents = ($!curr_tag eq any @!strip_tags).Bool;
        $!ignore_contents = False if $!is_closing_tag;

        return if not $!out;
        $!out = $!out ~ q{ }
            if $!emit_space and $!out.comb[*-1] ne " ";
    }

    method tag_quickend($/) {
        $!inside_tag = False;
    }
    method comment_start($/) { 
        $!inside_comment = True; 
    }

    method comment_end($/) { 
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
        self.tag_start($/);
        $!is_closing_tag = True;
    }

}

constant @DEFAULT_STRIP_TAGS = <title script style applet>;

sub strip_html(Str $html, 
        :$emit_space = True, 
        :@strip_tags = @DEFAULT_STRIP_TAGS) is export {

    my $a = HTML::Strip::Actions.new(
        :emit_space($emit_space),
        :strip_tags(@strip_tags));

    HTML::Strip::Grammar.parse($html, :actions($a));
    return $a.out();
}

