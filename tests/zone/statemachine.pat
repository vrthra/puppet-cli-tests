# Zone path
# --------------------------------------------------------------------
title 'zone path related.'

use 'tests/zone/defs'

clean
setup

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

take PuppetCli do
>[
apply -e "zone {smzone : ensure=>running, iptype=>shared, path=>'/tstzones/mnt' }"
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
>[
zoneadm -z smzone list -v
]
<[
/running/
]
end

>[
apply -e "zone {smzone : ensure=>configured, iptype=>shared, path=>'/tstzones/mnt' }"
]
<[
/ensure changed 'running' to 'configured'/
]

take XCli do
>[
ls -pld /tstzones
]
>[
(zoneadm -z smzone verify ; echo yes)
]

<[
?could not verify?
]
>[
zoneadm -z smzone list -v
]
<[
/configured/
]
end

end

clean
