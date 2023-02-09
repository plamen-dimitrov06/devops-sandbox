$packages = [ 'git' ]

package { $packages: }

vcsrepo { '/code':
    ensure => present,
    provider => git,
    source => 'https://github.com/shekeriev/do2-app-pack',
}

class { 'mysql::server':
    root_password => '12345',
    remove_default_accounts => true,
    restart => true,
    override_options => {
        mysqld => { bind-address => '0.0.0.0' }
    },
}

mysql::db { 'bulgaria' :
    user => 'root',
    password => '12345',
    host => '%',
    sql => [ '/code/app1/db/db_setup.sql' ],
    enforce_sql => true,
}

mysql::db { 'tools' :
    user => 'root',
    password => '12345',
    host => '%',
    sql => [ '/code/app4/db/db_setup.sql' ],
    enforce_sql => true,
}