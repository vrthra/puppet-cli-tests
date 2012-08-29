# Zone path
# --------------------------------------------------------------------
title 'zone path related.'

take PuppetCli do
>[
apply -e 'zone {zg : ensure=>absent}'
]
<[
/Finished catalog run in .*/
]

# Make it installed
# --------------------------------------------------------------------
>[
apply -e "zone {zg : ensure=>installed, iptype=>shared, path=>'$(pwd)/zg' }"
]
<[
/ensure: created/
]
# --------------------------------------------------------------------
>[
apply -e 'zone {zg : ensure=>absent}'
]
end
