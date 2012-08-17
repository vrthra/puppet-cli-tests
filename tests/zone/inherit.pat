title 'zone inherit path functionality.'
#cr '0'
take PuppetCli do

# --------------------------------------------------------------------
# inherit was removed in 5.11
unless %x[uname -r] =~ /5.10/
  show 'We can not run on Solaris 11'
  return 1
end

use 'tests/zone/defs'

clean
setup

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
apply -e 'zone {tstzone : ensure=>configured, path=>"/tstzones/mnt", inherit=>"/usr" }'
]
<[
/ensure: created/
]

# Should not create again
# --------------------------------------------------------------------

>[
apply -e 'zone {tstzone : ensure=>configured, path=>"/tstzones/mnt", inherit=>"/usr" }'
]
<[
?ensure: created?
]

>[
apply -e 'zone {tstzone : ensure=>configured, path=>"/tstzones/mnt", inherit=>["/usr","/sbin"] }'
]
<[
/ensure: created/
]

end

clean
