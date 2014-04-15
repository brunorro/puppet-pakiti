require 'puppet'

Facter.add(:packages) do
  confine :osfamily => 'Debian'
  setcode do
    rtn = {'type' => 'dpkg', 'packages' => []}
    fmt = %Q{'${Status} ${Package} ${Version} ${Architecture}\\n'}
    out = Facter::Core::Execution.exec("dpkg-query -W --showformat #{fmt}")

    out.split("\n").each do |l|
      desired, err, status, name, version, arch = l.split()
      if ['install','hold'].include?(desired)
        rtn['packages'] << {
          'name'    => name,
          'version' => version,
          'arch'    => arch
        }
      end
    end

    rtn
  end 
end

Facter.add(:packages) do
  confine :osfamily => ['RedHat','Suse']
  setcode do
    rtn = {'type' => 'rpm', 'packages' => []}
    fmt = %Q{'%{NAME} %|EPOCH?{%{EPOCH}}:{0}|:%{VERSION} %{RELEASE} %{ARCH}\\n'}
    out = Facter::Core::Execution.exec("rpm -qa --nodigest --nosignature --qf #{fmt}")

    out.split("\n").each do |l|
      name, version, release, arch = l.split()
      rtn['packages'] << {
        'name'    => name,
        'version' => version,
        'release' => release,
        'arch'    => arch
      }
    end

    rtn
  end 
end

# fallback for not-yet supported OS
Facter.add(:packages) do
  setcode do
    rtn = {'packages' => []}

    Puppet::Resource.indirection.search("package/", {}).each do |resource|
      unless [:absent,'purged'].include?( resource['ensure'] )
        unless rtn.has_key?('type')
          rtn['type'] = String(resource['provider'])
        end

        version = resource['ensure'].is_a?(Symbol) ?
          String(resource['ensure']) :
          resource['ensure']

        rtn['packages'] << {
          'name'    => resource.title,
          'version' => version
        }
      end
    end

    rtn
  end
end
