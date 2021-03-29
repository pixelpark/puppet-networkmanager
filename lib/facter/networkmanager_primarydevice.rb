def which(cmd)
  std_paths = ['/bin', '/sbin', '/usr/bin', '/usr/sbin', '/usr/local/bin', '/usr/local/sbin']
  exts = (ENV['PATHEXT']) ? ENV['PATHEXT'].split(';') : ['']
  ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
    exts.each do |ext|
      exe = File.join(path, "#{cmd}#{ext}")
      return exe if File.executable?(exe) && !File.directory?(exe)
    end
  end
  std_paths.each do |path|
    exts.each do |ext|
      exe = File.join(path, "#{cmd}#{ext}")
      return exe if File.executable?(exe) && !File.directory?(exe)
    end
  end
  nil
end


Facter.add(:networkmanager_primarydevice) do
  confine kernel: 'Linux'
  setcode do
    ip = which('ip')
    if ip
      cmd = 'ip -o link | awk -F": " \'$0 ~ "^2:*" {print $2}\''
      Facter::Core::Execution.execute(cmd)
    else
      nil
    end
  end
end
