# Zfs
# --------------------------------------------------------------------
title 'zfs related'

def clean
take XCli do
>[
zfs destroy -r tstpool/tstfs
zpool destroy tstpool
rm -rf /ztstpool
]
end
end

clean

take XCli do
>[
mkdir -p /ztstpool/mnt
mkdir -p /ztstpool/mnt2
mkfile 64m /ztstpool/dsk
zpool create tstpool /ztstpool/dsk
]
#zfs create -o mountpoint=/ztstzones/mnt tstpool/tstfs
end


take PuppetCli do
>[
apply -e "zfs { 'tstpool/tstfs': ensure=>present }"
]
<[
/ensure: created/
]

>[
apply -e "zfs { 'tstpool/tstfs': ensure=>present }"
]
<[
?ensure: created?
]

>[
apply -e "zfs { 'tstpool/tstfs': ensure=>absent }"
]
<[
/ensure: removed/
]

>[
apply -e "zfs { 'tstpool/tstfs': ensure=>present, mountpoint=>'/ztstpool/mnt' }"
]
<[
/ensure: created/
]
>[
apply -e "zfs { 'tstpool/tstfs': ensure=>present, mountpoint=>'/ztstpool/mnt2' }"
]
<[
/mountpoint changed '.ztstpool.mnt' to '.ztstpool.mnt2'/
]

end

clean
