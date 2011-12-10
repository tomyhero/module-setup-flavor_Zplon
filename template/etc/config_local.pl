+{
    cache => {
        servers => [ '127.0.0.1:11211' ],
    },
    cache_session => {
        servers => [ '127.0.0.1:11211' ],
    },
    database => {
        master => {
            dsn => "dbi:mysql:[% dist | lower %]_local",
            username => "dev_master",
            password => "oreb",
        },
        slaves => [
            {
                dsn => "dbi:mysql:[% dist | lower %]_local",
                username => "dev_slave",
                password => "oreb",
            }
        ],
    },
};
