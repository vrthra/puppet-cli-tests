puppet-cli-tests
================

puppet commandline tests

Usage:

    cd src/puppet
    git clone puppet-cli-tests
    mv puppet-cli-tests p

    sudo -E ./p/pat -v 1 -x debug -s p/tests/pkg/pkg.pat
    # or for the full test run
    sudo -E ./p/pat -v 1 -x debug -s p/tests/solaris.seq
    # or for a specified group(,s)
    sudo -E ./p/pat -v 1 -x debug -g zone -s p/tests/solaris.seq

