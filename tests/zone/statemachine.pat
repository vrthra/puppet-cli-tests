# Zone path
# --------------------------------------------------------------------
title 'zone path related.'
take PuppetCli do
>[
resource zone zg ensure=absent
]
>[
resource zfs myfs ensure=absent
]
>[
resource zpool zfspool ensure=absent
]
<[
/absent/
]
end

take XCli do
warn "Fix this."
>[
zpool destroy zfspool
rm -rf /zones
]
>[
echo /z*
]
<[
?zones?
]
>[
mkdir -p /zones/mnt
chmod -R 700 /zones
chmod -R 700 /zones/mnt
mkfile 64m /zones/dsk
]
>[
ls -pld /zones
ls -pld /zones/mnt
]
<[
/drwx------   .* .zones.$/
/drwx------   .* .zones.mnt.$/
]
end

take PuppetCli do

>[
apply -e "zpool{ zfspool: ensure=>present, disk=>'/zones/dsk' }"
]

<[
/Finished catalog run/
]
end

take PuppetCli do
>[
apply -e "zfs { 'zfspool/myfs': ensure=>present, mountpoint=>'/zones/mnt' }"
]
<[
/Finished catalog run/
]

take XCli do
warn "Fix this"
>[
chmod 700 /zones/mnt
]
>[
ls -pld /zones/mnt
]
<[
/drwx------   .* .zones.mnt.$/
]
end

>[
apply -e "zone {zg : ensure=>configured, iptype=>shared, path=>'/zones/mnt' }"
]
<[
/ensure: created/
]
>[
apply -e "zone {zg : ensure=>installed, iptype=>shared, path=>'/zones/mnt' }"
]
<[
/ ensure changed 'configured' to 'installed'/
]
# Make it installed
# --------------------------------------------------------------------
>[
apply -e 'zone {zg : ensure=>absent}'
]
<[
/Finished catalog run in .*/
]

>[
apply -e "zone {zg : ensure=>installed, iptype=>shared, path=>'/zones/mnt' }"
]
<[
/ensure: created/
]
# --------------------------------------------------------------------
>[
apply -e 'zone {zg : ensure=>absent}'
]
end
