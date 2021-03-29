#
# @summary Ensure and restarts NetworkManager Service
#
# @example Setting up NetworkManager service
#  class { 'networkmanager::service':
#    ensure       => 'running',
#    enable       => true,
#    manage       => true,
#    restart      => undef,
#  }
#
# @param service_name
#   The systemd service name of NetworkManager, usually 'NetworkManager'.
#
# @param enable
#   Whether a service should be enabled to start at boot.
#
# @param ensure
#   Whether a service should be running. Valid values are 'stopped', 'running', true, false.
#
# @param manage
#   Whether the service should be managed. If false, then this class has no function.
#
# @param restart
#   Specify a restart command manually. If left unspecified, the service will be stopped and then started.
#
# @api private
class networkmanager::service (
  String[1]                             $service_name = 'NetworkManager',
  Boolean                               $enable       = true,
  Optional[Variant[Boolean, String[1]]] $ensure       = 'running',
  Boolean                               $manage       = true,
  Optional[String[1]]                   $restart      = undef,
) {

  if $manage {

    case $ensure {
      true, false, 'running', 'stopped': {
        $_ensure = $ensure
      }
      default: {
        $_ensure = undef
      }
    }

    $hasrestart = $restart == undef

    service { 'NetworkManager':
      ensure     => $_ensure,
      name       => $service_name,
      enable     => $enable,
      restart    => $restart,
      hasrestart => $hasrestart,
    }
  }

}
