define pp::vmbuilder (
  $os,
  $vg,
  $ip,
  $netmask,
  $gateway,
  $dns,
  $bridge,
  $pointopoint = false,
  $domain = 'example.ru',
  $user   = 'example3301',
  $pass   = '$6$nhs9ONjvN$vSoNefH0pshU57VR3di3QABfsd8UzL/TX2njx30V9YO3qmR/kwY8iOyXltas1TbGmn9nwq0vNWR6EFfHIvScI.',  #eezeSh2equaifeifu5l
  $distribution = 'xenial',
  $pv     = '/dev/sda1',
  $cpu    = 4,
  $disk   = '30000',
  $memory = '8192',
  $tz     = 'Europe/Moscow',
  $mirror = 'mirror.yandex.ru',
  $pkg    = [  openssh-server,
                        acpid,
                        ntp,
                        ipmitool,
                        vim,
                        htop,
                        atop,
                        iotop,
                        etckeeper,
                        git-core,
                        nfs-common,
                        telnet,
                        tcpdump,
                        tmux,
                        lvm2,
                        iputils-tracepath,
                        bash-completion,
                        aptitude,
                        curl,
                        bc,
                        sysstat,
                        vim,
                        software-properties-common,
                        puppet,
                        man ],
) {


  package { 'virtinst':
    ensure => present,
  }

  $tmp_disk=$disk+300

  pp::lv_create { $name:
    vg => $vg,
    pv => $pv,
    size => "${tmp_disk}M"
  }

  case $os {
    'ubuntu': {
      $answer_file='preseed.cfg'
      $extra_args="locale=en_GB.UTF-8 console-setup/ask_detect=false keyboard-configuration/layoutcode=hu file=file:/tmp/${answer_file} vga=788 quiet"
      $additional_options=[ "--initrd-inject=/tmp/${answer_file}" ] 
      $location="http://${mirror}/ubuntu/dists/${distribution}/main/installer-amd64/"

      file { "/tmp/${answer_file}":
        ensure  => present,
        content => template("pp/vmbuilder/${answer_file}.erb"),
      }
    }
  
    'centos': {
      $answer_file='ks.cfg'
      $extra_args = "ks=ftp://g9-1.rg.net/centos/${answer_file}_${name} ksdevice=ens3 ip=${ip} netmask=${netmask} gateway=${gateway} dns=${dns} hostname=${name}.${domain}"
      $location="http://${mirror}/${os}/${distribution}/os/x86_64/"
      $additional_options=[ ]

      file { "/srv/ftp/centos/${answer_file}_${name}":
        ensure  => present,
#        path    => "/srv/ftp/centos/${answer_file}",
        content => template("pp/vmbuilder/${answer_file}.erb"),
      }
    }
    'default': {
      fail("Not support OS")
    }
  }

  $tmp_additional_options = [  '-d',
                "--name=${name}.${domain}",
                "--ram=${memory}",
                "--vcpus=${cpu}",
                '--autostart',
                '--os-type=linux',
                "--disk path=/dev/${vg}/${name},bus=virtio",
                "--location=${location}",
                "--network bridge=${bridge}",
                '--graphics vnc,port=-1,listen=127.0.0.1',
              ]

  $options = $tmp_additional_options + $additional_options + [ "--extra-args=\"${extra_args}\"" ]

  $cmd = "sudo virt-install ${options.delete("").join(" ")}"

  exec { "vmbuild-kvm-${name}":
    path      => ['/usr/bin','/bin','/sbin','/usr/sbin'],
    timeout   => '3000',
    command   => $cmd,
#    unless    => "test -d $disk_path/$hostname",
    require   => [ Pp::Lv_create[$name], Package['virtinst'] ],
    logoutput => 'true',
  }

}
