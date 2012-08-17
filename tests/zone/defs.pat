def clean
take XCli do
>[
zoneadm -z tstzone halt
zoneadm -z tstzone uninstall -F
zonecfg -z tstzone delete -F
rm -f /etc/zones/tstzone.xml
zfs destroy -r tstpool/tstfs
zpool destroy tstpool
rm -rf /tstzones
]
end
end

def setup
take XCli do
>[
mkdir -p /tstzones/mnt
chmod -R 700 /tstzones
mkfile 512m /tstzones/dsk
]
>[
ls -pld /tstzones
ls -pld /tstzones/mnt
]
<[
/drwx------   .* .tstzones.$/
/drwx------   .* .tstzones.mnt.$/
]
>[
zpool create tstpool /tstzones/dsk
zfs create -o mountpoint=/tstzones/mnt tstpool/tstfs
]
end

take XCli do
warn "Fix this"
>[
chmod 700 /tstzones/mnt
]
>[
ls -pld /tstzones/mnt
]
<[
/drwx------   .* .tstzones.mnt.$/
]
end

end
