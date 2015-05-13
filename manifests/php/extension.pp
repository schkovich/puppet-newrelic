define newrelic::php::extension (
  $extension,
  $ensure = 'present',
  $priority = 20,
) {

  Exec {
  #   default path minus games
    path    => '/bin:/usr/bin:/usr/local/bin: /sbin:/usr/sbin:/usr/local/sbin',
  }

  $sapi = delete($title, $extension)

  validate_re($ensure, '^(latest|present|installed|absent)$')
# no need for qualified since path is defined
  $command = $ensure ? {
    'absent' => 'php5dismod',
    default  => 'php5enmod'
  }
# same as above
  $unless = $ensure ? {
    'absent' => 'test ! -e',
    default  => 'test -e',
  }
# regex is idempotent. no changes will be made if there is a space after semicolon already
  exec { "priority_${sapi}_${extension}":
    command => "sed -ie 's/^;priority/; priority/g' /etc/php5/mods-available/${extension}.ini",
    onlyif  => "test -e /etc/php5/mods-available/${extension}.ini",
  }
# extension class should be responsible for service notification
  exec { "${command} -s ${sapi} ${extension}":
    unless  => "${unless} /etc/php5/${sapi}/conf.d/${priority}-${extension}.ini",
    require => Exec["priority_${sapi}_${extension}"]
  }

}
