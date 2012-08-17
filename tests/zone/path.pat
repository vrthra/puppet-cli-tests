# Zone path
# --------------------------------------------------------------------
title 'zone path.'

use 'tests/zone/defs'
clean
setup

take XCli do
>[
mkdir /tstzones/mnt2
]
>[
zfs create -o mountpoint=/tstzones/mnt2 tstpool/tstfs2
]

end

take PuppetCli do
>[
apply -e 'zone {tstzone : ensure=>absent}'
]
<[
/Finished catalog run in .*/
]

# Should require path.
>[
apply -e 'zone {tstzone : ensure=>configured, iptype=>shared }'
]
<[
/Error: Path is required/
]

# Make it configured
# --------------------------------------------------------------------
>[
apply -e 'zone {tstzone : ensure=>configured, iptype=>shared, path=>"/tstzones/mnt" }'
]
<[
/ensure: created/
]
# --------------------------------------------------------------------

>[
apply -e 'zone {tstzone : ensure=>configured, iptype=>shared, path=>"/tstzones/mnt" }'
]
<[
/Finished catalog run/
]

>[
apply -e 'zone {tstzone : ensure=>configured, iptype=>shared, path=>"/tstzones/mnt2" }'
]

<[
/path changed '.tstzones.mnt' to '.tstzones.mnt2'/
/Finished catalog run/
]


>[
apply -e 'zone {tstzone : ensure=>configured, iptype=>shared, path=>"/tstzones/mnt2" }'
]

<[
/Finished catalog run/
]

take XCli do
>[
/usr/sbin/zonecfg -z tstzone export
]
<[
/set zonepath=.*mnt2/
]
end

>[
apply -e 'zone {tstzone : ensure=>configured, iptype=>shared, path=>"/tstzones/mnt" }'
]
<[
/path changed '.tstzones.mnt2' to '.tstzones.mnt'/
/Finished catalog run/
]

take XCli do
>[
/usr/sbin/zonecfg -z tstzone export
]
<[
/set zonepath=.tstzones.mnt/
]
end
# /usr/lib/brand/ipkg/pkgcreatezone:pkglist= SUNWbip
>[
apply -e 'zone {tstzone : ensure=>installed}'
]
<[
/ensure changed 'configured' to 'installed'/
]

>[
apply -e 'zone {tstzone : ensure=>installed, path=>"/tstzones/mnt2" }'
]
<[
/Failed to apply configuration/
]

take XCli do
>[
/usr/sbin/zonecfg -z tstzone export
]
<[
/set zonepath=.tstzones.mnt/
]
end

end
take XCli do
>[
zfs destroy -r tstpool/tstfs2
]
end
clean

