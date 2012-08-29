title 'zpool related'
#cr '0'

take XCli do
>[
rm -rf dsk*
mkfile 100m dsk1 dsk2 dsk3 dsk5
mkfile 50m dsk4
]
end

take PuppetCli do
>[
resource zpool mypool ensure=absent
]
<[
/.*/
]

>[
apply -e "zpool{ mypool: ensure=>present, disk=>'$(pwd)/dsk1' }"
]
<[
/ensure: created/
]

>[
apply -e "zpool{ mypool: ensure=>present, disk=>'$(pwd)/dsk1' }"
]
<[
?ensure: created?
]
>[
apply -e "zpool{ mypool: ensure=>absent }"
]
<[
/ensure: removed/
]

>[
apply -e "zpool{ mypool: ensure=>present, disk=>['$(pwd)/dsk1','$(pwd)/dsk2'] }"
]
<[
/ensure: created/
]

take XCli do
>[
zpool list -H
]
<[
/mypool/
]
end

>[
resource zpool mypool
]
<[
/ensure => 'present'/
/disk   => .'.+dsk1 .+dsk2'./
]

>[
apply -e "zpool{ mypool: ensure=>absent }"
]
<[
/ensure: removed/
]

>[
apply -e "zpool{ mypool: ensure=>present, mirror=>['$(pwd)/dsk1','$(pwd)/dsk2', '$(pwd)/dsk3'] }"
]
<[
/ensure: created/
]

take XCli do
>[
zpool status -v mypool
]
<[
/mypool/
/mirror/
]
end

>[
resource zpool mypool
]
<[
/ensure => 'present'/
/mirror => .'.+dsk1 .+dsk2 .+dsk3'./
]
>[
apply -e "zpool{ mypool: ensure=>absent }"
]
<[
/ensure: removed/
]
>[
apply -e "zpool{ mypool: ensure=>present, raidz=>['$(pwd)/dsk1','$(pwd)/dsk2', '$(pwd)/dsk3'] }"
]
<[
/ensure: created/
]

take XCli do
>[
zpool status -v mypool
]
<[
/mypool/
/raidz/
]
end
>[
resource zpool mypool
]
<[
/ensure => 'present'/
/raidz  => .'.+dsk1 .+dsk2 .+dsk3'./
]

end
