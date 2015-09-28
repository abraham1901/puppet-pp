class pp::virtual_shorewall (
  $startup    = '1',
  $interface  = [ 'eth0' ],
  $options    = 'tcpflags,blacklist,nosmurfs',
) {

  class{'shorewall':
    startup => $startup
  }

  # If you want logging:
  #shorewall::params {
  # 'LOG':  value => 'debug';
  #}

  shorewall::zone {'net':
    type => 'ipv4';
  }

  shorewall::rule_section { 'NEW':
    order => 100;
  }

  $interface.each |$iface| {
    shorewall::interface { $iface:
      zone    => 'net',
      rfc1918  => true,
      options => $options;
    }
  }

  shorewall::policy {
    'fw-to-fw':
      sourcezone              =>      '$FW',
      destinationzone         =>      '$FW',
      policy                  =>      'ACCEPT',
      order                   =>      100;
    'fw-to-net':
      sourcezone              =>      '$FW',
      destinationzone         =>      'net',
      policy                  =>      'ACCEPT',
      order                   =>      110;
    'net-to-fw':
      sourcezone              =>      'net',
      destinationzone         =>      '$FW',
      policy                  =>      'ACCEPT',
      order                   =>      120;
  }

  # default Rules : ICMP
  shorewall::rule {
    'allicmp-to-host':
      source      => 'all',
      destination => '$FW',
      order       => 200,
      action      => 'AllowICMPs/ACCEPT';
  }
}

