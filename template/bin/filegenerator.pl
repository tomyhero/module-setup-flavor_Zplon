#!/usr/bin/env perl

use strict;
use warnings;
use FindBin::libs ;
use [% dist %]::FileGenerator;

[% dist %]::FileGenerator->run();


