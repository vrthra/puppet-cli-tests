# SMF
# --------------------------------------------------------------------
take PuppetCli do
>[
resource service myapp ensure=stopped
]
<[
/ensure => 'stopped'/
]
end

# --------------------------------------------------------------------
take XCli do
>[
rm -rf ./smf
mkdir -p ./smf
svcadm disable myapp
svccfg delete myapp
rm -f /lib/svc/method/myapp
rm -f /var/svc/manifest/application/myapp.xml
rm -f /opt/bin/myapp
mkdir -p /opt/bin
pkill -9 -f /opt/bin/myapp
]
end

# --------------------------------------------------------------------
take FileConn, '/lib/svc/method/myapp', 'w' do
>[
. /lib/svc/share/smf_include.sh

case "$1" in
  start) nohup /opt/bin/myapp & ;;
  stop) kill -9 $(cat /tmp/my.pidfile) ;;
  refresh) kill -9 $(cat /tmp/my.pidfile) ; nohup /opt/bin/myapp & ;;
  *) echo "Usage: $0 { start | stop | refresh }" ; exit 1 ;;
esac

exit $SMF_EXIT_OK
]
end
# --------------------------------------------------------------------

take FileConn, '/opt/bin/myapp', 'w' do
>[
echo $$ > /tmp/my.pidfile
sleep 5
]
end

# --------------------------------------------------------------------
take XCli do
>[
chmod 755 /lib/svc/method/myapp
]
>[
chmod 755 /opt/bin/myapp
]
end
# --------------------------------------------------------------------


# --------------------------------------------------------------------
take FileConn, '/var/svc/manifest/application/myapp.xml', 'w' do
>[
<?xml version="1.0"?>
<!DOCTYPE service_bundle SYSTEM "/usr/share/lib/xml/dtd/service_bundle.dtd.1">
<service_bundle type='manifest' name='myapp:default'>
  <service name='application/myapp' type='service' version='1'>
  <create_default_instance enabled='false' />
  <single_instance />
  <method_context> <method_credential user='root' group='root' /> </method_context>
  <exec_method type='method' name='start' exec='/lib/svc/method/myapp start' timeout_seconds="60" />
  <exec_method type='method' name='stop' exec='/lib/svc/method/myapp stop' timeout_seconds="60" />
  <exec_method type='method' name='refresh' exec='/lib/svc/method/myapp refresh' timeout_seconds="60" />
  <stability value='Unstable' />
  <template>
    <common_name> <loctext xml:lang='C'>Dummy</loctext> </common_name>
    <documentation>
      <manpage title='myapp' section='1m' manpath='/usr/share/man' />
    </documentation>
  </template>
</service>
</service_bundle>
]
end
# --------------------------------------------------------------------

# --------------------------------------------------------------------
take XCli do
>[
svccfg -v validate /var/svc/manifest/application/myapp.xml
]
>[
echo "" > /var/svc/log/application-myapp:default.log
]
end
# --------------------------------------------------------------------
take PuppetCli do
>[
resource service myapp ensure=running manifest=/var/svc/manifest/application/myapp.xml
]
<[
/ensure => 'running'/
]
end

take XCli do
>[
svcs -l application/myapp
]
<[
/state        online/
]

>[
cat /var/svc/log/application-myapp:default.log
]
<[
/.*/
]
end
