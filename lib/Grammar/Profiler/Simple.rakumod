my %timing;

my class ProfiledGrammarHOW is Metamodel::GrammarHOW {
    method find_method($obj, $name) {
        my $meth := callsame;
        return $meth if $meth.^name eq 'NQPRoutine' || $meth !~~ Any || $meth !~~ Regex;
        substr($name, 0, 1) eq '!' ||
        substr($name, 0, 8) eq 'dispatch' || 
        $name eq any(« parse CREATE Bool defined MATCH Stringy Str WHERE orig BUILD DESTROY »)
          ?? $meth
          !! -> $c, |args {
                my str $grammar = $c.^name;
                my %rules := %timing{$grammar} // (%timing{$grammar} := Hash.new);
                my str $rule = $meth.name;
                my %t := %rules{$rule} // (%rules{$rule} := Hash.new);

                use nqp;
                my int $start = nqp::time();
                my $result := $meth($c, |args);
                %t<time> += (nqp::time() - $start) / 1_000_000_000;  # nsecs -> secs
                ++%t<calls>;
                $result
            }
    }

    method publish_method_cache($obj) {
        # no caching, so we always hit find_method
    }
}

proto sub get-timing(|) is export { * }
multi sub get-timing() { %timing }
multi sub get-timing(Any:U $grammar) {
    %timing{$grammar.^name}
}
multi sub get-timing(Any:U $grammar, Any:U $rule) {
    %timing{$grammar.^name}{$rule.^name}
}
multi sub get-timing(Any:U $grammar, Str:D $rule) {
    %timing{$grammar.^name}{$rule}
}
multi sub get-timing(Str:D $grammar) {
    %timing{$grammar}
}
multi sub get-timing(Str:D $grammar, Str:D $rule) {
    %timing{$grammar}{$rule}
}

proto sub reset-timing(|) is export { * }
multi sub reset-timing(--> Empty) { %timing = () }
multi sub reset-timing(Any:U $grammar --> Empty) {
    %timing{$grammar.^name}:delete
}
multi sub reset-timing(Any:U $grammar, Any:U $rule --> Empty) {
    %timing{$grammar.^name}{$rule.^name}:delete
}
multi sub reset-timing(Any:U $grammar, Str:D $rule --> Empty) {
    %timing{$grammar.^name}{$rule}:delete
}
multi sub reset-timing(Str:D $grammar --> Empty) {
    %timing{$grammar}:delete
}
multi sub reset-timing(Str:D $grammar, Str:D $rule --> Empty) {
    %timing{$grammar}{$rule}:delete
}

my module EXPORTHOW { }
EXPORTHOW.WHO.<grammar> = ProfiledGrammarHOW;

=begin pod

=head1 NAME

Grammar::Profiler::Simple - Simple rule profiling for Raku grammars

=head1 SYNOPSIS

=begin code :lang<raku>

use Grammar::Profiler::Simple;

my grammar MyGrammar {
    rule MyRule {
        ...
    }
}

reset-timing;
MyGrammar.new.parse($string);

say "MyRule was called &get-timing(MyGrammar,MyRule)<calls> times";
say "The total time executing MyRule was &get-timing(MyGrammar,MyRule)<time> seconds";

=end code

=head1 DESCRIPTION

This module provides a simple profiler for Raku grammars. To enable
profiling simply add

=begin code :lang<raku>

use Grammar::Profiler::Simple;

=end code

to your code. Any grammar in the lexical scope of the C<use> statement
will automatically have profiling information collected when the
grammar is used.

There are 2 bits of timing information collected:  the number of times
each rule was called and the cumulative time that was spent executing
each rule.  For example:

say "MyRule was called &get-timing(MyGrammar,MyRule)<calls>} times";
say "The total time executing MyRule was &get-timing(MyGrammar,MyRule)<time>} seconds";

=head1 EXPORTED SUBROUTINES

=head2 reset-timing

Reset all time information collected since the start of the program or
since the last call to C<reset-timing> for all grammars, or for the
specified grammar only (and all its rules), or for the specified
grammar and rule only.

=begin code :lang<raku>

reset-timing;                     # all grammars and rules

reset-timing(MyGrammar);          # MyGrammar only

reset-timing(MyGrammar, MyRule);  # MyRule in MyGrammar only

=end code

=head2 get-timing

Either returns all time information collected since the start of the
program or since the last call to C<reset-timing> for all grammars,
or for the specified grammar only (and all its rules), or for the
specified grammar and rule only.  What is returned is always a C<Hash>.

=begin code :lang<raku>

my %t := get-timing;                       # %<grammar><rules><calls|time>

my %tg := get-timing(MyGrammar);           # %<rules><calls|time>

my %tgr := get-timing(MyGrammar, MyRule);  # %<calls|time>

=end code

=head1 AUTHOR

Jonathan Scott Duff

=head1 COPYRIGHT AND LICENSE

Copyright 2011 - 2017 Jonathan Scott Duff

Copyright 2018 - 2022 Raku Community

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: expandtab shiftwidth=4
