# Pkg
# --------------------------------------------------------------------
take XCli do
>[
rm -rf ./pkgrepo;
]
>[
mkdir -p ./pkgrepo;
]
>[
pkgrepo create ./pkgrepo
]
>[
pkgrepo set -s ./pkgrepo  repository/name=MyRepo
]
>[
pkgrepo set -s ./pkgrepo publisher/prefix=MyPub
]
>[
pkgrepo -s ./pkgrepo refresh
]

>[
svccfg -v -s application/pkg/server setprop pkg/inst_root=$(pwd)/pkgrepo
]
>[
svccfg -v -s application/pkg/server listprop pkg/inst_root
]
<[
/pkgrepo/
]
>[
svccfg -v -s application/pkg/server setprop pkg/readonly=false
]
>[
svcadm refresh svc:/application/pkg/server;
svcadm disable svc:/application/pkg/server;
svcadm enable svc:/application/pkg/server;
]
>[
svcadm restart svc:/application/pkg/server
]
end

take XCli do
>[
rm -rf fakeroot
]
#>[
#./install.rb --destdir=./fakeroot 2>/dev/null
#]

>[
mkdir -p fakeroot/f/usr/bin/x
]
>[
mkdir -p fakeroot/f/etc/lst
]

>[
touch fakeroot/f/usr/bin/usrcmd
]
>[
touch fakeroot/f/etc/lst/mylist.lst
]
>[
find fakeroot
]
<[
/x/
/lst/
]

end

cont = true
while cont do
  `svcs -l application/pkg/server`.split("\n").each do |l|
    cont = false if l.chomp =~ /online/
  end
  sleep(1)
end

take PkgCmd, "http://localhost", "mypkg@0.0.1" do
>[
pkgsend -s http://localhost import ./fakeroot
]
end

take XCli do

>[
pkg unset-publisher MyPub >/dev/null 2>&1
pkg set-publisher -g http://localhost MyPub
]
>[
pkg refresh
pkg publisher -H
]
<[
/MyPub/
]

end

take PuppetCli do
>[
resource package mypkg ensure=absent
]
<[
/ensure => 'absent'/
]

# ---------------------------------------------------------------
#  Ensure that default provider is set.
# ---------------------------------------------------------------
>[
resource package mypkg ensure=present
]
<[
/ensure => '0.0.1'/
]
end

take PkgCmd, "http://localhost", "mypkg@0.0.2" do
>[
pkgsend -s http://localhost import ./fakeroot
]
end

take XCli do
>[
pkg refresh
]
end

# ---------------------------------------------------------------
# Do not upgrade until we say latest
# ---------------------------------------------------------------
take PuppetCli do
>[
resource package mypkg ensure=present
]
<[
/ensure => '0.0.1'/
]

>[
resource package mypkg ensure=latest
]
<[
/ensure => '0.0.2'/
]

end
# ---------------------------------------------------------------
# When there are more than one options to upgrade, choose latest
# ---------------------------------------------------------------

take PkgCmd, "http://localhost", "mypkg@0.0.3" do
>[
pkgsend -s http://localhost import ./fakeroot
]
end

take PkgCmd, "http://localhost", "mypkg@0.0.4" do
>[
pkgsend -s http://localhost import ./fakeroot
]
end

take XCli do
>[
pkg refresh
]
end

take PuppetCli do
>[
resource package mypkg ensure=latest
]
<[
/ensure => '0.0.4'/
]
end

