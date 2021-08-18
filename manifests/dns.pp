# @summary Manages the DNS informations about a particular NetworkManager connection
#
# @example
#   networkmanager::dns { 'System link':
#       nameservers   => ['8.8.8.8', '8,.8.4.4', '1.1.1.1'],
#       searchdomains => ['example.com', 'uhu-banane.de', 'uhu-banane.net'],
#       dns_options   => ['timeout:1', 'attempts:2', 'use-vc'],
#       notify_daemon => true,
#   }
#
# @param nameservers
#   An array of the IP addresses of the resolvers to use. At least one address has to be given,
#   but if exactly one address is given, a warning will be omitted.
#
# @param searchdomains
#   An array of DNS search domains. At least one domain has to be given.
#
# @param dns_options
#   A string or an array of strings with resolving options. Please note not to use whitespaces
#   inside the strings, only use comma to separate options inside a string. If not given (or undef),
#   the options are not managed. To remove existing options use an empty string '' as a value.
#
# @param connection
#   The name of the NetworkManager connection. If not given, the name of the resource will be used
#   as the name of the connection.
#
# @param notify_daemon
#   A boolean flag, whether to notify the NetworkManager daemon after DNS changes. In case of a
#   notification the NetworkManager daemon is rewriting /etc/resolv.conf immediately. In this way
#   this resorce can be used to manage /etc/resolv.conf.
#   **CAUTION**: If you are using another module for managing /etc/resolv.conf (like saz-resolv_conf),
#   this option should be set to false to prevent a Ping-Pong game between those two modules. In this
#   case this resource is only intended to ensure a correct /etc/resolv.conf immediately after a reboot.
#
define networkmanager::dns (
  Array[Stdlib::IP::Address::Nosubnet, 1]     $nameservers,
  Array[String[1], 1]                         $searchdomains,
  Optional[Variant[Array[String[1]], String]] $dns_options,
  Optional[String[1]]                         $connection    = undef,
  Boolean                                     $notify_daemon = true,
) {

  unless $facts['networkmanager_nmcli_path'] {
    fail("Did not found NetworkManager command line tool 'nmcli'.")
  }

  $nmcli = $facts['networkmanager_nmcli_path']

  if $connection {
    $_connection = $connection
  } else {
    $_connection = $name
  }

  if $nameservers.length() == 1 {
    notify { "Only one nameserver was given for NetworkManager connection ${_connection}.": loglevel => warning }
  }

  $used_nameservers = $nameservers.join(',')
  $has_nameservers  = $facts['networkmanager_dns'][$_connection]['nameserver'].join(',')

  unless $used_nameservers == $has_nameservers {
    exec { "update nameserver nmcli connection ${_connection}":
      command => "${nmcli} connection modify ${_connection} ipv4.dns ${used_nameservers}",
    }

    if $notify_daemon {
      Exec["update nameserver nmcli connection ${_connection}"] ~> Class['networkmanager::service']
    }
  }

  $used_searchdomains = $searchdomains.join(',')
  $has_searchdomains = $facts['networkmanager_dns'][$_connection]['search'].join(',')

  unless $used_searchdomains == $has_searchdomains {
    exec { "update searchdomains nmcli connection ${_connection}":
      command => "${nmcli} connection modify ${_connection} ipv4.dns-search '${used_searchdomains}'",
    }

    if $notify_daemon {
      Exec["update searchdomains nmcli connection ${_connection}"] ~> Class['networkmanager::service']
    }
  }

  unless $dns_options == undef {
    if is_array($dns_options) {
      $used_options = $dns_options.join(',')
    } else {
      $used_options = $dns_options
    }

    $has_options = $facts['networkmanager_dns'][$_connection]['options'].join(',')
    unless $used_options == $has_options {
      exec { "update dns-options nmcli connection ${_connection}":
        command => "${nmcli} connection modify ${_connection} ipv4.dns-options '${used_options}'",
      }
      if $notify_daemon {
        Exec["update dns-options nmcli connection ${_connection}"] ~> Class['networkmanager::service']
      }
    }
  }
}
