+{
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
