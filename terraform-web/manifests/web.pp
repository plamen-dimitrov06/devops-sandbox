$packages = [ 'apache2', 'php', 'php-mysqlnd', 'git' ]

package { $packages: }

vcsrepo { '/code':
    ensure => present,
    provider => git,
    source => 'https://github.com/shekeriev/do2-app-pack',
}

file { '/etc/apache2/sites-available/vhost-app1.conf':
  ensure => present,
  content => 'Listen 8081
<VirtualHost *:8081>
        DocumentRoot "/var/www/app1"
</VirtualHost>',
}

file { '/etc/apache2/sites-available/vhost-app4.conf':
  ensure => present,
  content => 'Listen 8082
<VirtualHost *:8082>
        DocumentRoot "/var/www/app4"
</VirtualHost>',
}

file { '/etc/apache2/sites-enabled/vhost-app1.conf':
    ensure => 'link',
    target => '/etc/apache2/sites-available/vhost-app1.conf',
    notify => Service[apache2],
}

file { '/etc/apache2/sites-enabled/vhost-app4.conf':
    ensure => 'link',
    target => '/etc/apache2/sites-available/vhost-app4.conf',
    notify => Service[apache2],
}

file { '/var/www/app1':
    ensure => 'directory',
    recurse => true,
    source => '/code/app1/web/',
}

file { '/var/www/app4':
    ensure => 'directory',
    recurse => true,
    source => '/code/app4/web/',
}

service { apache2:
  ensure => running,
  enable => true,
}