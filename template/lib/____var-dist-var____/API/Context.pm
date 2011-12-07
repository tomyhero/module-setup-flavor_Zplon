package [% dist %]::API::Context;
use Ze::Class;
extends '[% dist %]::WAF::Context';


__PACKAGE__->load_plugins( 'Ze::WAF::Plugin::Encode','Ze::WAF::Plugin::JSON', 'Ze::WAF::Plugin::AntiCSRF','Ze::WAF::Plugin::FillInForm');


EOC;
