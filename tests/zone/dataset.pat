#cr '0'
title 'zone dataset specific tests.'

use 'tests/zone/defs'

clean
setup

take XCli do
>[
zfs create tstpool/xx
zfs create tstpool/yy
zfs create tstpool/zz
]

end

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
apply -e 'zone {tstzone : ensure=>configured, path=>"/tstzones/mnt" }'
]
<[
/ensure: created/
]

# Make it configured
# --------------------------------------------------------------------
>[
apply -e 'zone {tstzone : ensure=>configured, dataset=>"tstpool/xx", path=>"/tstzones/mnt" }'
]
<[
/defined 'dataset' as .'tstpool.xx'./
]

>[
apply -e 'zone {tstzone : ensure=>configured, dataset=>"tstpool/yy", path=>"/tstzones/mnt" }'
]
<[
/dataset changed 'tstpool.xx' to .'tstpool.yy'./
]

>[
apply -e 'zone {tstzone : ensure=>configured, dataset=>["tstpool/yy","tstpool/zz"], path=>"/tstzones/mnt" }'
]
<[
/dataset changed 'tstpool.yy' to .'tstpool.yy', 'tstpool.zz'./
]

>[
apply -e 'zone {tstzone : ensure=>configured, dataset=>["tstpool/xx","tstpool/zz"], path=>"/tstzones/mnt" }'
]
<[
/dataset changed 'tstpool.yy,tstpool.zz' to .'tstpool.xx', 'tstpool.zz'./
]

>[
apply -e 'zone {tstzone : ensure=>configured, dataset=>[], path=>"/tstzones/mnt" }'
]
<[
/dataset changed 'tstpool.zz,tstpool.xx' to ../
]

end

clean
