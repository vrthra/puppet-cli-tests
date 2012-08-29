# Zone path
# --------------------------------------------------------------------
title 'zone path related.'

def clean
take XCli do
>[
zoneadm -z smzone halt
zoneadm -z smzone uninstall -F
zonecfg -z smzone delete -F
rm -f /etc/zones/smzone.xml
zfs destroy -r smpool/smfs
zpool destroy smpool
rm -rf /zones
]
end
end

def setup
take XCli do
>[
mkdir -p /zones/mnt
chmod -R 700 /zones
mkfile 512m /zones/dsk
]
>[
ls -pld /zones
ls -pld /zones/mnt
]
<[
/drwx------   .* .zones.$/
/drwx------   .* .zones.mnt.$/
]
>[
zpool create smpool /zones/dsk
zfs create -o mountpoint=/zones/mnt smpool/smfs
]
end
end

clean
setup

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

take PuppetCli do
>[
apply -e "zone {smzone : ensure=>configured, iptype=>shared, path=>'/zones/mnt' }"
]
<[
/ensure: created/
]

take XCli do
>[
(zoneadm -z smzone verify ; echo yes)
]
<[
?could not verify?
]
end

>[
apply -e "zone {smzone : ensure=>installed, iptype=>shared, path=>'/zones/mnt' }"
]
<[
/ensure changed 'configured' to 'installed'/
]

>[
apply -e "zone {smzone : ensure=>running, iptype=>shared, path=>'/zones/mnt' }"
]
<[
/ensure changed 'installed' to 'running'/
]
return 1
# Make it installed
# --------------------------------------------------------------------
>[
apply -e 'zone {smzone : ensure=>absent}'
]
<[
/Finished catalog run in .*/
]

#zfs create /rpool/zones
#zfs create /rpool/zones/test
>[
apply -e "zone {smzone : ensure=>installed, iptype=>shared, path=>'/zones/mnt' }"
]
<[
/ensure: created/
]
# --------------------------------------------------------------------
>[
apply -e 'zone {smzone : ensure=>absent}'
]
end

clean
