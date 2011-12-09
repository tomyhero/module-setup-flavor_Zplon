package [% dist %]::PC::Context;
use Ze::Class;
extends '[% dist %]::WAF::Context';

__PACKAGE__->load_plugins( 'Ze::WAF::Plugin::Encode','Ze::WAF::Plugin::AntiCSRF','Ze::WAF::Plugin::FillInForm');


EOC;
