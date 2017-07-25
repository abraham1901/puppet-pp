# Virtual shorewall class
class pp::virtual_shorewall (
  $startup    = '1',
  $interface  = [ 'eth0' ],
  $zone       = 'net',
  $options    = 'tcpflags,blacklist,nosmurfs',
) {

  class{'shorewall':
    startup => $startup
  }

  # If you want logging:
  #shorewall::params {
  # 'LOG':  value => 'debug';
  #}

  shorewall::zone {$zone:
    type => 'ipv4';
  }

  shorewall::rule_section { 'NEW':
    order => 300;
  }

  $interface.each |$iface| {
    shorewall::interface { $iface:
      zone    => $zone,
      rfc1918 => true,
      options => $options;
    }
  }

  shorewall::policy {
    'fw-to-fw':
      sourcezone              =>      '$FW',
      destinationzone         =>      '$FW',
      policy                  =>      'ACCEPT',
      order                   =>      120;
    'fw-to-net':
      sourcezone              =>      '$FW',
      destinationzone         =>      $zone,
      policy                  =>      'ACCEPT',
      order                   =>      130;
    'net-to-fw':
      sourcezone              =>      $zone,
      destinationzone         =>      '$FW',
      policy                  =>      'ACCEPT',
      order                   =>      140;
  }

  # default Rules : ICMP
  shorewall::rule {
    'allicmp-to-host':
      source      => 'all',
      destination => '$FW',
      order       => 301,
      action      => 'AllowICMPs/ACCEPT';
  }
}

