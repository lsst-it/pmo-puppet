# Check if Pingfederate service is installed.rb
Facter.add(:pf_svc) do
  setcode do
    File.exists?('/etc/systemd/system/pingfederate.service')
  end
end
Facter.add(:nginx_source) do
  setcode do
    File.exists?('/usr/src/nginx-1.22.1/configure')
  end
end
Facter.add(:yourls_config) do
  setcode do
    File.exists?('/etc/nginx/YOURLS/user/config.php')
  end
end
Facter.add(:nginx_pid) do
  setcode do
    File.exists?('/etc/systemd/system/nginx.service.d/override.conf')
  end
end
