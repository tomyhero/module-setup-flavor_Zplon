package [% dist %]::PC;
use Ze::Class;
extends 'Ze::WAF';
use [% dist %]::Config;

if( [% dist %]::Config->instance->get('debug') ) {
    with 'Ze::WAF::Profiler';
};

EOC;
