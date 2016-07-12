class pp::myshorewall (
  $shorewall_test = true,
  $options    = 'tcpflags,blacklist,nosmurfs',
  $zone       = 'net',
  $mywhitelists = [ "all:${whitelists} all" ],
  $drops,
  $tmp_interface = false,
) {

  if $tmp_interface {
    $interface = $tmp_interface
  } else {
    if has_interface_with('br0') {
      $interface = [ 'br0' ]
    } else {
      $interface = [ 'eth0' ]
    }
  }

  class { 'pp::virtual_shorewall':
    interface  => $interface,
    zone       => $zone,
    options     => $options,
  }



#  $whitelists = join($whitelist_address, ",")

  class { 'shorewall::blrules':
    whitelists  => $mywhitelists,
    drops       => $drops,
  }

  if $shorewall_test {
    cron { 'shorewall_test':
      command => "shorewall clear",
      user    => root,
      minute  => '*',
      hour    => '*',
    }
  } else {
    cron { 'shorewall_test':
      command => "/usr/sbin/service shorewall status",
      user    => root,
      minute  => '*/10',
      hour    => '*',
    }
  }
}

