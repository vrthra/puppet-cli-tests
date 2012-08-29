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



General Advice
==============

do not trust puppet

Do NOT trust Puppet

DO NOT TRUST PUPPET

Adding new tests
===============

- Use platform specific tools to ensure that we are starting on a clean slate,
- Use the external tools to setup the environment
- Do the test with puppet
- Verify using external tools (Do not trust puppet output)
- Clean up using external tools
