package [% dist %]::FileGenerator;
use strict;
use warnings;
use parent 'Ze::FileGenerator';

sub _module_pluggable_options {
    return (
        except => ['[% dist %]::FileGenerator::Base'],
    );
};


1;
