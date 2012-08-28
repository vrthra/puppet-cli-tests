# Zfs
# --------------------------------------------------------------------

take PuppetCli do
>[
apply -e "zfs { 'zfspool/myfs': ensure=>absent }"
]
<[
//
]

>[
apply -e "zpool{ zfspool: ensure=>absent }"
]
<[
/.*/
]
end


take XCli do
>[
rm -f zdsk
]
>[
mkfile 64m zdsk
]
end

take PuppetCli do
>[
apply -e "zpool{ zfspool: ensure=>present, disk=>'$(pwd)/zdsk' }"
]
<[
/ensure: created/
]
end

take PuppetCli do
>[
apply -e "zfs { 'zfspool/myfs': ensure=>present }"
]
<[
/ensure: created/
]

>[
apply -e "zfs { 'zfspool/myfs': ensure=>present }"
]
<[
?ensure: created?
]

>[
apply -e "zfs { 'zfspool/myfs': ensure=>absent }"
]
<[
/ensure: removed/
]
end


