title 'zone inherit path related'
#cr '0'
take PuppetCli do

# --------------------------------------------------------------------
# inherit was removed in 5.11
unless %x[uname -r] =~ /5.10/
  show 'We can not run on Solaris 11'
  return 1
end

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
apply -e 'zone {z3 : ensure=>configured, path=>"/export/z3", inherit=>"/usr" }'
]
<[
/ensure: created/
]

# Should not create again
# --------------------------------------------------------------------

>[
apply -e 'zone {z3 : ensure=>configured, path=>"/export/z3", inherit=>"/usr" }'
]
<[
?ensure: created?
]

>[
apply -e 'zone {z3 : ensure=>configured, path=>"/export/z3", inherit=>["/usr","/sbin"] }'
]
<[
/ensure: created/
]

end
