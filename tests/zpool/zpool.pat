title 'zpool related'

#cr '0'

def clean
take XCli do
>[
zpool destroy tstpool
rm -rf /ztstpool/
]
end

end

clean

take XCli do
>[
mkdir -p /ztstpool/mnt
mkfile 100m /ztstpool/dsk1 /ztstpool/dsk2 /ztstpool/dsk3 /ztstpool/dsk5
mkfile 50m /ztstpool/dsk4
]
end

take PuppetCli do
>[
apply -e "zpool{ tstpool: ensure=>present, disk=>'/ztstpool/dsk1' }"
]
<[
/ensure: created/
]

>[
apply -e "zpool{ tstpool: ensure=>present, disk=>'/ztstpool/dsk1' }"
]
<[
?ensure: created?
]
>[
apply -e "zpool{ tstpool: ensure=>absent }"
]
<[
/ensure: removed/
]

>[
apply -e "zpool{ tstpool: ensure=>present, disk=>['/ztstpool/dsk1','/ztstpool/dsk2'] }"
]
<[
/ensure: created/
]

take XCli do
>[
zpool list -H
]
<[
/tstpool/
]
end

>[
resource zpool tstpool
]
<[
/ensure => 'present'/
/disk   => .'.+dsk1 .+dsk2'./
]

>[
apply -e "zpool{ tstpool: ensure=>absent }"
]
<[
/ensure: removed/
]

>[
apply -e "zpool{ tstpool: ensure=>present, mirror=>['/ztstpool/dsk1','/ztstpool/dsk2', '/ztstpool/dsk3'] }"
]
<[
/ensure: created/
]

take XCli do
>[
zpool status -v tstpool
]
<[
/tstpool/
/mirror/
]
end

>[
resource zpool tstpool
]
<[
/ensure => 'present'/
/mirror => .'.+dsk1 .+dsk2 .+dsk3'./
]
>[
apply -e "zpool{ tstpool: ensure=>absent }"
]
<[
/ensure: removed/
]
>[
apply -e "zpool{ tstpool: ensure=>present, raidz=>['/ztstpool/dsk1','/ztstpool/dsk2', '/ztstpool/dsk3'] }"
]
<[
/ensure: created/
]

take XCli do
>[
zpool status -v tstpool
]
<[
/tstpool/
/raidz/
]
end

>[
resource zpool tstpool
]
<[
/ensure => 'present'/
/raidz  => .'.+dsk1 .+dsk2 .+dsk3'./
]

end

clean
