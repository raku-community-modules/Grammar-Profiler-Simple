[![Actions Status](https://github.com/raku-community-modules/Grammar-Profiler-Simple/actions/workflows/test.yml/badge.svg)](https://github.com/raku-community-modules/Grammar-Profiler-Simple/actions)

NAME
====

Grammar::Profiler::Simple - Simple rule profiling for Raku grammars

SYNOPSIS
========

```raku
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
```

DESCRIPTION
===========

This module provides a simple profiler for Raku grammars. To enable profiling simply add

```raku
use Grammar::Profiler::Simple;
```

to your code. Any grammar in the lexical scope of the `use` statement will automatically have profiling information collected when the grammar is used.

There are 2 bits of timing information collected: the number of times each rule was called and the cumulative time that was spent executing each rule. For example:

say "MyRule was called &get-timing(MyGrammar,MyRule)<calls>} times"; say "The total time executing MyRule was &get-timing(MyGrammar,MyRule)<time>} seconds";

EXPORTED SUBROUTINES
====================

reset-timing
------------

Reset all time information collected since the start of the program or since the last call to `reset-timing` for all grammars, or for the specified grammar only (and all its rules), or for the specified grammar and rule only.

```raku
reset-timing;                     # all grammars and rules

reset-timing(MyGrammar);          # MyGrammar only

reset-timing(MyGrammar, MyRule);  # MyRule in MyGrammar only
```

get-timing
----------

Either returns all time information collected since the start of the program or since the last call to `reset-timing` for all grammars, or for the specified grammar only (and all its rules), or for the specified grammar and rule only. What is returned is always a `Hash`.

```raku
my %t := get-timing;                       # %<grammar><rules><calls|time>

my %tg := get-timing(MyGrammar);           # %<rules><calls|time>

my %tgr := get-timing(MyGrammar, MyRule);  # %<calls|time>
```

AUTHOR
======

Jonathan Scott Duff

COPYRIGHT AND LICENSE
=====================

Copyright 2011 - 2017 Jonathan Scott Duff

Copyright 2018 - 2022 Raku Community

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

