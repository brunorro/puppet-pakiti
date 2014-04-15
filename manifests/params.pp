class pakiti::params {
  $version = 4
  $report = false
  $stringify_fail = false
  $send_fail = true
  $debug = false

  $packages = $::packages
  $servers = []
  $server_path = '/feed/'
  $host = $::fqdn
  $organization = "Domain ${::domain}"
  $os = "${::operatingsystem} ${::operatingsystemrelease}"
  $arch = $::hardwaremodel
  $kernel = $::kernelrelease
}
