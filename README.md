# Puppet Pakiti module

This module gets list of installed software via supported package
manager and sends them to your patch monitoring service
[Pakiti](https://github.com/CESNET/pakiti3) (old web
http://pakiti.sourceforge.net/).

### Requirements

Module has been tested on:

* Puppet 3.4 and Facter 2.x (structured facts support is required!)
* OS:
 * Debian 6,7
 * RHEL/CentOS 6
 * SLES/SLED 11 SP3

Required modules:

* stdlib (https://github.com/puppetlabs/puppetlabs-stdlib)

Note: basic functionality should be available on any platform and
package manager supported by Puppet itself.

# Quick Start

Setup client

```puppet
include pakiti
```

Full configuration options:

```puppet
class { 'perun':
  packages       => $::packages,  # hash with list of packages
  servers        => ['...'],      # list of Pakiti server names
  server_path    => '/feed/',     # server URL path
  host           => '...',        # reported hostname
  organization   => '...',        # reported organization (tag)
  os             => '...',        # reported OS
  arch           => '...',        # reported architecture
  kernel         => '...',        # reported running kernel
  report         => false|true,   # report back vulnerable packages?
  stringify_fail => false|true,   # fail or err when $packages is not hash
  send_fail      => false|true,   # fail or err on send error
  debug          => false|true,   # debug send request
}
```

Example:

```puppet
class { 'perun':
  servers   => ['pakiti.localdomain:443'],
  report    => false,
  send_fail => false,
}
```

## Standalone run

```shell
puppet apply --no-stringify_facts -e "class {'pakiti': servers => ['pakiti.localdomain:443'] }"
```

Full example: 

```shell
mkdir -p ~/.puppet/modules/
git clone https://github.com/puppetlabs/puppetlabs-stdlib.git ~/.puppet/modules/stdlib
git clone https://github.com/CERIT-SC/puppet-pakiti.git ~/.puppet/modules/pakiti
puppet apply --no-stringify_facts -e "class {'pakiti': servers => ['pakiti.localdomain:443'] }"
```

***

CERIT Scientific Cloud, <support@cerit-sc.cz>
