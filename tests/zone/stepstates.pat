# Zone path
# --------------------------------------------------------------------
title 'zone path related.'

use 'tests/zone/defs'

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

>[
apply -e "zone {smzone : ensure=>installed, iptype=>shared, path=>'/zones/mnt' }"
]
<[
/ensure changed 'running' to 'installed'/
]

>[
apply -e "zone {smzone : ensure=>configured, iptype=>shared, path=>'/zones/mnt' }"
]
<[
/ensure changed 'installed' to 'configured'/
]
>[
apply -e 'zone {smzone : ensure=>absent}'
]
<[
/ensure: removed/
]
end

clean
