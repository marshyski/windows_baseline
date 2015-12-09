class windows_baseline {

  # Create directories
  file {
    [
     'c:\temp',
     'c:\test',
    ]:
      ensure => directory,
      owner => 'Administrator',
      group => 'BUILTIN\Administrators',
  }

  # Turn off Windows Update and Remote Manager Services
  service {
    [
     'wuauserv',
     'rasman',
    ]:
    ensure => 'stopped',
    enable => 'false',
  }

  # Create user Sponge Bob
  user { 'spongebob':
    ensure   => present,
    comment  => 'Who lives in a pineapple under the sea',
    groups   => ['Users','Administrators'],
    password => 'SquarePants!123',
  }

  # Stage EXE on server
  file {'c:\temp\windirstat1_1_2_setup.exe':
    ensure  => present,
    mode    => '0755',
    source  => 'puppet:///modules/windows_baseline/windirstat1_1_2_setup.exe',
    require => File['c:\temp'],
  }

  # Install WinDirStat
  package { 'WinDirStat 1.1.2':
    ensure          => present,
    source          => 'c:\temp\windirstat1_1_2_setup.exe',
    install_options => '/S',
    require         => File['c:\temp\windirstat1_1_2_setup.exe'],
  }

  # Add WINRM firewall rule
  windows_firewall::exception { 'WINRM':
    ensure       => present,
    direction    => 'in',
    action       => 'Allow',
    enabled      => 'yes',
    protocol     => 'TCP',
    local_port   => '5985',
    display_name => 'Windows Remote Management HTTP-In',
    description  => 'Inbound rule for Windows Remote Management via WS-Management. [TCP 5985]',
  }

  # Create scheduled task
  scheduled_task { 'Defrag Drives':
    ensure    => present,
    enabled   => true,
    command   => 'C:\Windows\System32\defrag.exe',
    arguments => '/C', # /C – do all volumes
    trigger   => {
      schedule   => weekly,
      on         => ['sun'],
      start_time => '01:00',
      start_date => '2015-01-01', #required so agent doesn’t see as constantly changed
    }
  }

  # Need Registry module installed, make sure Registry path exists
  registry_key { 'HKLM\SOFTWARE\TimSki\Core':
    ensure => present,
  }

  # Add Date if ImageAppliedDate doesn't exist on system
  exec { 'Image Applied Date':
    command  => '$Date=Get-Date -Format g; Set-ItemProperty -Path HKLM:\SOFTWARE\TimSki\Core -Name ImageAppliedDate -Value $Date',
    provider => powershell,
    unless   => 'C:\Windows\System32\reg.exe query "HKEY_LOCAL_MACHINE\SOFTWARE\TimSki\Core" /v ImageAppliedDate',
    require  => Registry_key['HKLM\SOFTWARE\TimSki\Core'],
  }

  # Enabled .NET feature and IIS role
  windowsfeature { 'NET-Framework-Core': }

  windowsfeature { 'Web-WebServer':
    installsubfeatures => true,
  }

}

