+{
    debug => 1,
    cache => {
        servers => [ '127.0.0.1:11211' ],
    },
    cache_session => {
        servers => [ '127.0.0.1:11211' ],
    },
    database => {
        master => {
            dsn => "dbi:mysql:[% dist | lower %]_devel",
            username => "dev_master",
            password => "[% dist | lower %]",
        },
        slaves => [
            {
                dsn => "dbi:mysql:[% dist | lower %]_devel",
                username => "dev_slave",
                password => "[% dist | lower %]",
            }
        ],
    },
    url => {
        pc => 'http://localhost.dev:5000',
    },
    cookie_session => {
        namespace => '[% dist | lower %]_session',
    },
    middleware => {
        pc => [
            {
                name => 'StackTrace',
            },
#            {
#                name => 'ServerStatus::Lite',
#                opts => {
#                    path => '/___server-status',
#                    allow => [ '127.0.0.1','10.0.0.0/8'],
#                    sc[% dist | lower %]oard => '/var/run/server',
#                },
#            },
#            {
#                name => "ErrorDocument",
#                opts => {
#                    500 => $home->file('htdocs-static/pc/doc/500.html'),
#                    502 => $home->file('htdocs-static/pc/doc/500.html')
#                },
#            },
            {
                name => 'HTTPExceptions',
            },
        ],
    },
};
