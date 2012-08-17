cr 4840

use 'tests/zone/defs'
clean
setup

take FileConn, '/tmp/4840.pp', 'w' do
>[
zfs { "tstpool/tstfs":
  mountpoint => "/ztstpool/mnt",
  ensure => present,
}

file { "/ztstpool/mnt":
  ensure => directory,
  mode => 0700,
  require => Zfs["tstpool/tstfs"],
}

zone { tstzone:
  autoboot => true,
  path => '/ztstpool/mnt',
  sysidcfg => '/tmp/myzone.cfg',
  iptype => exclusive,
  require => File["/ztstpool/mnt"],
  ip => vnic3,
}
]
end

take PuppetCli do
>[
apply /tmp/4840.pp 
]
<[
/ensure: created/
]
end

clean
