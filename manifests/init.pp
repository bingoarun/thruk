# thruk
#
# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include thruk
class thruk {
  
  $thruk_conf = hiera('thruk_peers')

  if $::osfamily == 'redhat' {
    $package = 'httpd'
    package { 'labs-consol-stable' :
      ensure          => 'present',
      provider        => 'rpm',
      source          => 'https://labs.consol.de/repo/stable/rhel7/i386/labs-consol-stable.rhel7.noarch.rpm',
      install_options => ['--nosignature'],
    }
  }

  if $::osfamily == 'debian' {
    $package = 'apache2'
    apt::source { 'labs-consol-stable' :
      location => 'http://labs.consol.de/repo/stable/ubuntu' ,
      repos    => 'main',
      key      => {
        'id'     => 'F8C1CA08A57B9ED7',
        'server' => 'keys.gnupg.net',
      },
    }
  }

    package { 'thruk':
    ensure          => 'present',
    #install_options => ['--nogpgcheck'],
    notify          => Service[$package],
  }

  file {

    '/etc/thruk/thruk_local.conf':
      content => template('thruk/thruk.erb'),
      owner   => apache,
      group   => apache,
      mode    => '0644',
      notify  => Service[$package],
      require => Package['thruk'];

    '/etc/thruk/cgi.cfg':
      source  => 'puppet:///modules/thruk/thruk_cgi.cfg',
      owner   => apache,
      group   => apache,
      mode    => '0644',
      notify  => Service[$package],
      require => Package['thruk'];

  }

  service { $package:
    ensure => running,
    enable => true,
  }
}
