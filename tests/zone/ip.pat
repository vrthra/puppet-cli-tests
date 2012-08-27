cr '0'
title 'zone'
take PuppetCli

# Make sure that the zone is absent.
# --------------------------------------------------------------------
>[
apply -e 'zone {z3 : ensure=>absent}'
]
<[
/Finished catalog run in .*/
]

# Make it configured
# --------------------------------------------------------------------
>[
apply -e 'zone {z3 : ensure=>configured, iptype=>shared, path=>"/export/z3" }'
]
<[
/ensure: created/
]

# Should not create again
# --------------------------------------------------------------------

>[
apply -e 'zone {z3 : ensure=>configured, iptype=>shared, path=>"/export/z3" }'
]
<[
?ensure: created?
]

# IP switch
# --------------------------------------------------------------------
>[
apply -e 'zone {z3 : ensure=>configured, iptype=>exclusive, path=>"/export/z3" }'
]
<[
/iptype changed 'shared' to 'exclusive'/
]

# IP switch
# --------------------------------------------------------------------
>[
apply -e 'zone {z3 : ensure=>configured, iptype=>exclusive, path=>"/export/z3" }'
]
<[
?iptype changed 'shared' to 'exclusive'?
]

>[
apply -e 'zone {z3 : ensure=>configured, iptype=>shared, path=>"/export/z3" }'
]
<[
/iptype changed 'exclusive' to 'shared'/
]

# IP assign
# --------------------------------------------------------------------

>[
apply -e 'zone {z3 : ensure=>configured, iptype=>shared, path=>"/export/z3", ip=>"eg0001" }'
]
<[
Error: ip must contain interface name and ip address separated by a ":"
]

>[
apply -e 'zone {z3 : ensure=>configured, iptype=>shared, path=>"/export/z3", ip=>"eg0001:1.1.1.1" }'
]
<[
/defined 'ip' as .'eg0001:1.1.1.1'./
]

# IP assign multiple
# --------------------------------------------------------------------

>[
apply -e 'zone {z3 : ensure=>configured, iptype=>shared, path=>"/export/z3", ip=>["eg0001:1.1.1.1", "eg0002:1.1.1.2"] }'
]
<[
/ ip changed 'eg0001:1.1.1.1' to .'eg0001:1.1.1.1', 'eg0002:1.1.1.2'./
]

>[
apply -e 'zone {z3 : ensure=>configured, iptype=>shared, path=>"/export/z3", ip=>["eg0001:1.1.1.1", "eg0002:1.1.1.3"] }'
]
<[
/ip changed 'eg0001:1.1.1.1,eg0002:1.1.1.2' to .'eg0001:1.1.1.1', 'eg0002:1.1.1.3'./
]

>[
apply -e 'zone {z3 : ensure=>configured, iptype=>shared, path=>"/export/z3", ip=>["eg0001:1.1.1.1", "eg0002:1.1.1.3"] }'
]
<[
?ip changed?
/Finished catalog run/
]

