#cr '0'
title 'zone check iptype and ip configuration.'

use 'tests/zone/defs'

clean
setup

take PuppetCli do

# Make sure that the zone is absent.
# --------------------------------------------------------------------
>[
apply -e 'zone {tstzone : ensure=>absent}'
]
<[
/Finished catalog run in .*/
]

# Make it configured
# --------------------------------------------------------------------
>[
apply -e 'zone {tstzone : ensure=>configured, iptype=>shared, path=>"/tstzones/mnt" }'
]
<[
/ensure: created/
]

# Should not create again
# --------------------------------------------------------------------

>[
apply -e 'zone {tstzone : ensure=>configured, iptype=>shared, path=>"/tstzones/mnt" }'
]
<[
?ensure: created?
]

# IP switch
# --------------------------------------------------------------------
>[
apply -e 'zone {tstzone : ensure=>configured, iptype=>exclusive, path=>"/tstzones/mnt" }'
]
<[
/iptype changed 'shared' to 'exclusive'/
]

# IP switch
# --------------------------------------------------------------------
>[
apply -e 'zone {tstzone : ensure=>configured, iptype=>exclusive, path=>"/tstzones/mnt" }'
]
<[
?iptype changed 'shared' to 'exclusive'?
]

>[
apply -e 'zone {tstzone : ensure=>configured, iptype=>shared, path=>"/tstzones/mnt" }'
]
<[
/iptype changed 'exclusive' to 'shared'/
]

# IP assign
# --------------------------------------------------------------------

>[
apply -e 'zone {tstzone : ensure=>configured, iptype=>shared, path=>"/tstzones/mnt", ip=>"eg0001" }'
]
<[
Error: ip must contain interface name and ip address separated by a ":"
]

>[
apply -e 'zone {tstzone : ensure=>configured, iptype=>shared, path=>"/tstzones/mnt", ip=>"eg0001:1.1.1.1" }'
]
<[
/defined 'ip' as .'eg0001:1.1.1.1'./
]

# IP assign multiple
# --------------------------------------------------------------------

>[
apply -e 'zone {tstzone : ensure=>configured, iptype=>shared, path=>"/tstzones/mnt", ip=>["eg0001:1.1.1.1", "eg0002:1.1.1.2"] }'
]
<[
/ ip changed 'eg0001:1.1.1.1' to .'eg0001:1.1.1.1', 'eg0002:1.1.1.2'./
]

>[
apply -e 'zone {tstzone : ensure=>configured, iptype=>shared, path=>"/tstzones/mnt", ip=>["eg0001:1.1.1.1", "eg0002:1.1.1.3"] }'
]
<[
/ip changed 'eg0001:1.1.1.1,eg0002:1.1.1.2' to .'eg0001:1.1.1.1', 'eg0002:1.1.1.3'./
]

>[
apply -e 'zone {tstzone : ensure=>configured, iptype=>shared, path=>"/tstzones/mnt", ip=>["eg0001:1.1.1.1", "eg0002:1.1.1.3"] }'
]
<[
?ip changed?
/Finished catalog run/
]
end

