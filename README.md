# networkmanager


## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with networkmanager](#setup)
    * [Setup requirements](#setup-requirements)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

Get and set parameters of NetworkManager controlled connections.

In the first iteration this module supports management of two aspects
of the NetworkManager:

* Management of the NetworkManager daemon - whther it is running and enabled or not
* Management of DNS information of particular NetworkManager connections.
  This could be done on three different ways:
  * Either by configurig a global Configuration file below `/etc/NetworkManager/conf.d`,
  * or by setting the DNS parameters of the primary NetworkManager connection (whichever it is),
  * or by setting the DNS parameters of one or more named NetworkManager connections.

## Setup

### Setup Requirements 

This module requires following:

* Puppet >= 6.0
* the module puppetlabs-stdlib >= 7.0.0

This module ist supported only for operating systems using NetworkManager. If the NetworkManager
command line tool **nmcli** could not be found, the module fails immediately.

This module was currently tested on:
* CentOS-7 and CentOS-8
* Oracle Enterprise Linux 7

## Usage

### Simple Including the module

The following two examples are simply including the networkmanager module. The further
configuration must be done via hieradata.

```puppet
include networkmanager
```

or 

```puppet
contain networkmanager
```

### Instantiation as a class

The following example is instatiating this module class with nearly all parameters:

```puppet
class {'networkmanager':
    enable_global_dns     => false,
    manage_dns            => true,
    nameservers           => ['8.8.8.8', '8.8.4.4', '1.1.1.1'].
    dns_searchdomains     => ['example.com', 'uhu-banane.de', 'uhu-banane.net'],
    dns_options           => ['timeout:1', 'attempts:2', 'use-vc'],
    manage_service        => true.
    ensure_service        => running,
    enable_service        => true,
    dns_notify_daemon     => false,
    connection_dnsoptions => {
      wifi1               => {
        nameservers       => ['172.28.1.2', '172.30.1.2'],
        searchdomains     => ['home.example.com'],
        dns_options       => ['timeout:3, 'attempts:3', 'use-vc'],
        notify_daemon     => true,
      },
    },
}
```

### Setup of hieradata

All parameters of the networkmanager module could be configured as hieradata.
But be aware, that all parameters are looked up with a first lookup. If you want to make
a deep lookup, yu have to set the lookup options by yourself.

```yaml
---
networkmanager::enable_global_dns: false
networkmanager::manage_dns: true
networkmanager::nameservers:
  - '8.8.8.8'
  - '8.8.4.4'
  - '1.1.1.1'
networkmanager::dns_searchdomains:
  - 'example.com'
  - 'uhu-banane.de'
  - 'uhu-banane.net'
networkmanager::dns_options:
  - 'timeout:1'
  - 'attempts:2'
  - 'use-vc'
networkmanager::manage_service: true
networkmanager::ensure_service: running
networkmanager::enable_service: true
networkmanager::dns_notify_daemon: false
networkmanager::connection_dnsoptions:
  wifi1:
    nameservers:
      - '172.28.1.2'
      - '172.30.1.2'
    searchdomains:
      - 'home.example.com'
    dns_options:
      - 'timeout:3'
      - 'attempts:3'
      - 'use-vc'
    notify_daemon: true
```

#### Parameters


## Limitations

The development of this module has even started, so the amount on functionality
is not so giant.

Don't hasitate to bring here new ideas, how to improve this module.

## Development

In the Development section, tell other users the ground rules for contributing
to your project and how they should submit their work.

[1]: https://puppet.com/docs/pdk/latest/pdk_generating_modules.html
[2]: https://puppet.com/docs/puppet/latest/puppet_strings.html
[3]: https://puppet.com/docs/puppet/latest/puppet_strings_style.html
