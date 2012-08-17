def clean
take XCli do
>[
userdel monitor
groupdel monitor

]
end
end

clean

take FileConn, '/tmp/5752.pp', 'w' do
>[
user { 'monitor':
    uid      => '472',
    gid      => '472',
    home     => '/tmp',
    shell    => '/bin/bash',
    password => 'NP',
    ensure   => 'present',
    require  => Group['monitor'],
}

group { 'monitor':
    gid    => '472',
    ensure => 'present',
}

cron { "manual-puppet":
    command => "agent",
    user => "root",
    hour => "*",
    minute => [30, 31],
    ensure => present,
}

cron { "myjob":
    command => "/opt/bin/test.pl",
    user    => "monitor",
    hour    => "*",
    minute  => [0,5,10,15,20,25,30,35,40,45,50,55],
    ensure  => present,
    require => User['monitor'],
}

]
end

take XCli do
>[
echo "10 3 * * * /usr/bin/tstcmd" >> /var/spool/cron/crontabs/root
]
end

take PuppetCli do
>[
apply /tmp/5752.pp 
]
<[
/ensure: created/
]
end

take XCli do
>[
crontab -l 
]
<[
/tstcmd/
]
end

take PuppetCli do
>[
apply -e "cron { 'tstcmd': command => '/usr/bin/tstcmd', user=>'root', ensure=>absent, }"
]
<[
/.*/
]
>[
apply -e "cron { 'manual-puppet': command => 'agent', user=>'root', ensure=> absent, }"
]
<[
/.*/
]
>[
apply -e "cron { 'myjob': command => '/opt/bin/test.pl', user=> 'monitor', ensure  => absent, }"
]
<[
/.*/
]
end

clean
