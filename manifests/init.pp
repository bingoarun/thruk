# thruk
#
# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include thruk
class thruk {

  package { 'labs-consol-stable' :
    ensure => 'present',
    provider => 'rpm',
    source => 'https://labs.consol.de/repo/stable/rhel7/i386/labs-consol-stable.rhel7.noarch.rpm',
    install_options => ['--nosignature'],
  }

  package { 'thruk':
    ensure => 'present',
    install_options => ['--nogpgcheck'],
    notify  => Service['httpd'],
  }

  $thruk_conf = hiera('thruk_peers')

  file {

    '/etc/thruk/thruk_local.conf':
      content => template('thruk/thruk.erb'),
      owner   => apache,
      group   => apache,
      mode    => '0644',
      notify  => Service['httpd'],
      require => Package['thruk'];

#    '/etc/thruk/htpasswd':
#      source  => 'puppet:///modules/thruk/htpasswd',
#      owner   => apache,
#      group   => apache,
#      mode    => '0644',
#      notify  => Service['httpd'],
#      require => Package['thruk'];

    '/etc/thruk/cgi.cfg':
      source  => 'puppet:///modules/thruk/thruk_cgi.cfg',
      owner   => apache,
      group   => apache,
      mode    => '0644',
      notify  => Service['httpd'],
      require => Package['thruk'];

  }

  service { 'httpd':
    ensure  => running,
    enable  => true,
  }
}
