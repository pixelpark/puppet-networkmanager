# @summary Manages NetworkManager connections
#
# @author Marko Weltzer <marko.weltzer@pixelpark.com>
# @author Frank Brehm <frank.brehm@pixelpark.com>
#
# @example using simple include
#   include networkmanager
#
# @example using class
#   class {'networkmanager':
#       enable_global_dns     => false,
#       manage_dns            => true,
#       nameservers           => ['8.8.8.8', '8.8.4.4', '1.1.1.1'].
#       dns_searchdomains     => ['example.com', 'uhu-banane.de', 'uhu-banane.net'],
#       dns_options           => ['timeout:1', 'attempts:2', 'use-vc'],
#       manage_service        => true.
#       ensure_service        => running,
#       enable_service        => true,
#       dns_notify_daemon     => false,
#       connection_dnsoptions => {
#         wifi1               => {
#           nameservers       => ['172.28.1.2', '172.30.1.2'],
#           searchdomains     => ['home.example.com'],
#           dns_options       => ['timeout:3', 'attempts:3', 'use-vc'],
#           notify_daemon     => true,
#         },
#       },
#   }
#
# @example using hieradata
#   ---
#   networkmanager::enable_global_dns: false
#   networkmanager::manage_dns: true
#   networkmanager::nameservers:
#     - '8.8.8.8'
#     - '8.8.4.4'
#     - '1.1.1.1'
#   networkmanager::dns_searchdomains:
#     - 'example.com'
#     - 'uhu-banane.de'
#     - 'uhu-banane.net'
#   networkmanager::dns_options:
#     - 'timeout:1'
#     - 'attempts:2'
#     - 'use-vc'
#   networkmanager::manage_service: true
#   networkmanager::ensure_service: running
#   networkmanager::enable_service: true
#   networkmanager::dns_notify_daemon: false
#   networkmanager::connection_dnsoptions:
#     wifi1:
#       nameservers:
#         - '172.28.1.2'
#         - '172.30.1.2'
#       searchdomains:
#         - 'home.example.com'
#       dns_options:
#         - 'timeout:3'
#         - 'attempts:3'
#         - 'use-vc'
#       notify_daemon: true
#
# @param enable_global_dns
#   By enabling this, NetworkManager will not use the connections specific dns settings.
#   Instead it will generate a file with the desired dns settings.
#   Those parameters are then the default, even if connection specific settings are present.
#
# @param global_nameservers
#   An array of the IP addresses for the nameservers for the global setting.
#
# @param global_searchdomains
#   An array of DNS search domains for the global setting.
#
# @param global_dns_options
#   A string or an array of strings with resolving options for the global setting.
#   If omitted, no global resolving optios are set.
#
# @param global_conffile
#   The config file for global dns settings. Should be under /etc/NetworkManager/conf.d
#
# @param manage_dns
#   Whether we want to manage dns of the primary NetworkManager connection.
#
# @param nameservers
#   An array of the IP addresses of the resolvers to use for the primary NetworkManager connection.
#   At least one address has to be given, but if exactly one address is given, a warning will be omitted.
#
# @param dns_searchdomains
#   An array of DNS search domains to use for the primary NetworkManager connection.
#   At least one domain has to be given.
#
# @param dns_options
#   A string or an array of strings with resolving options to use for the primary NetworkManager connection.
#   Please note not to use whitespaces inside the strings, only use comma to separate options inside
#   a string. If not given (or undef), the options are not managed.
#   To remove existing options use an empty string '' as a value.
#
# @param manage_service
#   Whether we want to manage the NetworkManager service.
#
# @param service_ensure
#   Whether a service should be running. Valid values are 'stopped', 'running', true, false.
#
# @param service_name
#   The systemd service name of NetworkManager, usually 'NetworkManager'.
#
# @param enable_service
#   Whether a service should be enabled to start at boot.
#
# @param restart_service
#   Specify a restart command manually. If left unspecified, the service will be stopped and then started.
#
# @param dns_notify_daemon
#   A boolean flag, whether to notify the NetworkManager daemon after DNS changea on the primary
#   NetworkManager connections. In case of a notification the NetworkManager daemon is rewriting
#   /etc/resolv.conf immediately. In this way this resorce can be used to manage /etc/resolv.conf.
#   **CAUTION**: If you are using another module for managing /etc/resolv.conf (like saz-resolv_conf),
#   this option should be set to false to prevent a Ping-Pong game between those two modules. In this
#   case manage_dns is only intended to ensure a correct /etc/resolv.conf immediately after a reboot.
#
# @param connection_dnsoptions
#   A hash for creating networkmanager::dns resources for managing DNS options on different NetworkManager
#   connections. Be sure not to include the primary NetworkManager connection, if manage_dns is true.
#
class networkmanager (
  Boolean                                     $enable_global_dns,
  Array[Stdlib::IP::Address::Nosubnet]        $global_nameservers,
  Array[String[1]]                            $global_searchdomains,
  Optional[Variant[Array[String[1]], String]] $global_dns_options,
  Optional[Stdlib::Absolutepath]              $global_conffile,
  Boolean                                     $manage_dns,
  Array[Stdlib::IP::Address::Nosubnet]        $nameservers,
  Array[String[1], 1]                         $dns_searchdomains,
  Optional[Variant[Array[String[1]], String]] $dns_options,
  Boolean                                     $manage_service,
  Optional[Variant[Boolean, String[1]]]       $ensure_service,
  String[1]                                   $service_name,
  Boolean                                     $enable_service,
  Optional[String[1]]                         $restart_service,
  Boolean                                     $dns_notify_daemon     = true,
  Optional[Hash]                              $connection_dnsoptions = undef,
){

  unless $facts['networkmanager_nmcli_path'] {
    fail("Did not found NetworkManager command line tool 'nmcli'.")
  }

  if $enable_global_dns {

    if $global_dns_options {
      if is_array($global_dns_options) {
        $real_dns_options = join($global_dns_options, ',')
      }
      else {
        $real_dns_options = $global_dns_options
      }
    }
    else {
      $real_dns_options = undef
    }

    file { $global_conffile:
      ensure  => file,
      mode    => '0644',
      content => template("${module_name}/dns.erb"),
      notify  => Class['networkmanager::service']
    }
  }
  else {
      file { $global_conffile:
        ensure => absent,
        notify => Class['networkmanager::service']
      }
  }

  class { 'networkmanager::service':
    ensure       => $ensure_service,
    service_name => $service_name,
    enable       => $enable_service,
    manage       => $manage_service,
    restart      => $restart_service,
  }

  if $manage_dns {

    $primary_connection = $facts['networkmanager_primaryconnection']

    if $primary_connection {
      networkmanager::dns { $primary_connection:
          nameservers   => $nameservers,
          searchdomains => $dns_searchdomains,
          dns_options   => $dns_options,
          notify_daemon => $dns_notify_daemon,
      }
    }
    else {
      notify { 'Did not found a primary NetworkManager connection.': loglevel => warning }
    }

  }

  if $connection_dnsoptions {
    create_resources('networkmanager::dns', $connection_dnsoptions)
  }

}
