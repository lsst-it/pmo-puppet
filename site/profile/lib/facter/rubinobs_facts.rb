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
