def clean
take XCli do
>[
rm -rf ./smf
mkdir -p ./smf
svcadm disable tstapp
svccfg delete tstapp
rm -f /lib/svc/method/tstapp
rm -f /var/svc/manifest/application/tstapp.xml
rm -f /opt/bin/tstapp
mkdir -p /opt/bin
pkill -9 -f /opt/bin/tstapp
]
end
end
