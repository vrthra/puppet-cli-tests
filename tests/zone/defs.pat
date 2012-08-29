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
