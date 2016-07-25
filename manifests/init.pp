class pakiti (
  $packages       = $pakiti::params::packages,
  $servers        = $pakiti::params::servers,
  $server_path    = $pakiti::params::server_path,
  $host           = $pakiti::params::host,
  $organization   = $pakiti::params::organization, # aka tag
  $site           = $pakiti::params::site,
  $os             = $pakiti::params::os,
  $arch           = $pakiti::params::arch,
  $kernel         = $pakiti::params::kernel,
  $report         = $pakiti::params::report,
  $stringify_fail = $pakiti::params::stringify_fail,
  $send_fail      = $pakiti::params::send_fail,
  $ssl_verify     = $pakiti::params::ssl_verify,
  $debug          = $pakiti::params::debug
) inherits pakiti::params {

  validate_string($host, $organization, $os, $arch, $kernel, $server_path)
  validate_bool($report, $send_fail, $stringify_fail)

  if ! is_hash($packages) and ! $stringify_fail {
    err("\$packages is not hash, disable stringify_facts on ${host}")
  } else {
    validate_hash($packages)

    if ($::servername != '') and ($::servername != $host) {
      $_proxy = 1
    } else {
      $_proxy = 0
    }

    $_servers = flatten([$servers])
    $_type = $packages['type']
    $_packages = $packages['packages']
    $_report = $report ? {
      true    => 1,
      default => 0,
    }

    validate_array($_packages, $_servers)
    validate_string($_type)

    if size($_servers) == 0 {
      fail('No servers specified')
    } elsif size($_servers) > 1 {
      fail('More servers specified, only 1 currently supported')
    }

    if size($server_path) == 0 {
      fail('Empty $server_path')
    }

    $response = pakiti_send(
      $_servers,
      $server_path,
      {
        'host'    => $host,
        'tag'     => $organization,
        'site'    => $site,
        'os'      => $os,
        'arch'    => $arch,
        'kernel'  => $kernel,
        'version' => $pakiti::params::version,
        'report'  => $_report,
        'proxy'   => $_proxy,
        'type'    => $_type,
      },
      $_packages,
      $ssl_verify,
      $debug
    )

    if $response != '' {
      if $send_fail {
        fail("Pakiti send failed: ${response}")
      } else {
        err("Pakiti send failed: ${response}")
      }
    }
  }
}
