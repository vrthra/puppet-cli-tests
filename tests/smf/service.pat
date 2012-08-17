# SMF
# --------------------------------------------------------------------
title 'service smf'
use 'tests/smf/defs'

clean
# --------------------------------------------------------------------
take FileConn, '/lib/svc/method/tstapp', 'w' do
>[
. /lib/svc/share/smf_include.sh

case "$1" in
  start) nohup /opt/bin/tstapp & ;;
  stop) kill -9 $(cat /tmp/tst.pidfile) ;;
  refresh) kill -9 $(cat /tmp/tst.pidfile) ; nohup /opt/bin/tstapp & ;;
  *) echo "Usage: $0 { start | stop | refresh }" ; exit 1 ;;
esac

exit $SMF_EXIT_OK
]
end
# --------------------------------------------------------------------

take FileConn, '/opt/bin/tstapp', 'w' do
>[
echo $$ > /tmp/tst.pidfile
sleep 5
]
end

# --------------------------------------------------------------------
take XCli do
>[
chmod 755 /lib/svc/method/tstapp
]
>[
chmod 755 /opt/bin/tstapp
]
end
# --------------------------------------------------------------------


# --------------------------------------------------------------------
take FileConn, '/var/svc/manifest/application/tstapp.xml', 'w' do
>[
<?xml version="1.0"?>
<!DOCTYPE service_bundle SYSTEM "/usr/share/lib/xml/dtd/service_bundle.dtd.1">
<service_bundle type='manifest' name='tstapp:default'>
  <service name='application/tstapp' type='service' version='1'>
  <create_default_instance enabled='false' />
  <single_instance />
  <method_context> <method_credential user='root' group='root' /> </method_context>
  <exec_method type='method' name='start' exec='/lib/svc/method/tstapp start' timeout_seconds="60" />
  <exec_method type='method' name='stop' exec='/lib/svc/method/tstapp stop' timeout_seconds="60" />
  <exec_method type='method' name='refresh' exec='/lib/svc/method/tstapp refresh' timeout_seconds="60" />
  <stability value='Unstable' />
  <template>
    <common_name> <loctext xml:lang='C'>Dummy</loctext> </common_name>
    <documentation>
      <manpage title='tstapp' section='1m' manpath='/usr/share/man' />
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
svccfg -v validate /var/svc/manifest/application/tstapp.xml
]
>[
echo "" > /var/svc/log/application-tstapp:default.log
]
end
# --------------------------------------------------------------------
take PuppetCli do
>[
resource service tstapp ensure=running manifest=/var/svc/manifest/application/tstapp.xml
]
<[
/ensure => 'running'/
]
end

take XCli do
>[
svcs -l application/tstapp
]
<[
/state        online/
]

>[
cat /var/svc/log/application-tstapp:default.log
]
<[
/.*/
]
end

clean
