#!/usr/bin/perl

use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'Crypter',
    AUTHOR       => q{Ivan Trunaev},
    EXE_FILES 	 => [ './bin/crypter' ],
);

1;
