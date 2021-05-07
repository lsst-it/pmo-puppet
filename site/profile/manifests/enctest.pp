# profile for testing encryption of sensitive data
class profile::enctest (Sensitive
$test_password,
$file_content,
) {
file { 'c:\backups':
  ensure  => directory,
}
file { 'c:\backups\encrypted.txt':
  ensure  => file,
  content => unwrap($file_content).node_encrypt::secret
}
}

