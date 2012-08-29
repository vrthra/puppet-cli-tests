#cr '0'
title 'zone dataset related.'
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
apply -e 'zone {z3 : ensure=>configured, path=>"/export/z3" }'
]
<[
/ensure: created/
]

# Make it configured
# --------------------------------------------------------------------
>[
apply -e 'zone {z3 : ensure=>configured, dataset=>xx, path=>"/export/z3" }'
]
<[
/defined 'dataset' as .'xx'./
]

>[
apply -e 'zone {z3 : ensure=>configured, dataset=>yy, path=>"/export/z3" }'
]
<[
/dataset changed 'xx' to .'yy'./
]

>[
apply -e 'zone {z3 : ensure=>configured, dataset=>['yy','zz'], path=>"/export/z3" }'
]
<[
/dataset changed 'yy' to .'yy', 'zz'./
]

>[
apply -e 'zone {z3 : ensure=>configured, dataset=>['xx','zz'], path=>"/export/z3" }'
]
<[
/dataset changed 'yy,zz' to .'xx', 'zz'./
]

>[
apply -e 'zone {z3 : ensure=>configured, dataset=>[], path=>"/export/z3" }'
]
<[
/dataset changed 'zz,xx' to ../
]
