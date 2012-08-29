# Zone path
# --------------------------------------------------------------------
title 'zone path related.'

take PuppetCli do
>[
apply -e 'zone {z3 : ensure=>absent}'
]
<[
/Finished catalog run in .*/
]

# Should require path.
>[
apply -e 'zone {z3 : ensure=>configured, iptype=>shared }'
]
<[
/Error: Path is required/
]

# Make it configured
# --------------------------------------------------------------------
>[
apply -e 'zone {z3 : ensure=>configured, iptype=>shared, path=>"/export/z3" }'
]
<[
/ensure: created/
]
# --------------------------------------------------------------------

>[
apply -e 'zone {z3 : ensure=>configured, iptype=>shared, path=>"/export/z3" }'
]
<[
/Finished catalog run/
]

>[
apply -e 'zone {z3 : ensure=>configured, iptype=>shared, path=>"/export/z4" }'
]

<[
/path changed '.export.z3' to '.export.z4'/
/Finished catalog run/
]


>[
apply -e 'zone {z3 : ensure=>configured, iptype=>shared, path=>"/export/z4" }'
]

<[
/Finished catalog run/
]

take XCli do
>[
/usr/sbin/zonecfg -z z3 export
]
<[
/set zonepath=.*z4/
]
end

>[
apply -e 'zone {z3 : ensure=>configured, iptype=>shared, path=>"/export/z3" }'
]
<[
/path changed '.export.z4' to '.export.z3'/
/Finished catalog run/
]

take XCli do
>[
/usr/sbin/zonecfg -z z3 export
]
<[
/set zonepath=.export.z3/
]
end

>[
apply -e 'zone {z3 : ensure=>installed}'
]
<[
/ensure changed 'configured' to 'installed'/
]

>[
apply -e 'zone {z3 : ensure=>installed, path=>"/export/z4" }'
]
<[
/Failed to apply configuration/
]

take XCli do
>[
/usr/sbin/zonecfg -z z3 export
]
<[
/set zonepath=.export.z3/
]
end

end
