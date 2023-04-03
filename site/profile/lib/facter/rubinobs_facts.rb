# Check if Pingfederate service is installed.rb
Facter.add(:pf_svc) do
    setcode do
      File.exists?('/etc/systemd/system/pingfederate.service')
    end
  end
