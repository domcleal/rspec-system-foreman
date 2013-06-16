require 'spec_helper_system'

describe 'foreman_installer_install' do
  before :each do
    # Cleanup
    if node.facts['osfamily'] == 'RedHat'
      shell 'yum --disablerepo=\* --enablerepo=foreman\* clean all'
      shell 'rpm -e foreman-release'
      shell 'rpm -e foreman-installer'
      shell 'rm -rf /etc/yum.repos.d/foreman* /usr/share/foreman-installer'
    elsif node.facts['osfamily'] == 'Debian'
      shell 'dpkg -P foreman-installer'
      shell 'rm -rf /etc/apt/sources.list.d/foreman* /usr/share/foreman-installer'
    end
  end

  it 'should install from stable repo by default' do
    foreman_installer_install
    if node.facts['osfamily'] == 'RedHat'
      shell 'cat /etc/yum.repos.d/foreman.repo' do |r|
        r.stdout =~ %r{/releases/latest}
      end
    elsif node.facts['osfamily'] == 'Debian'
      shell 'cat /etc/apt/sources.list.d/foreman.list' do |r|
        r.stdout.include? ' stable '
      end
    end
    shell 'test -d /usr/share/foreman-installer/foreman' do |r|
      r.exit_code.should == 0
    end
  end

  it 'should install from repo option' do
    if node.facts['osfamily'] == 'RedHat'
      foreman_installer_install :repo => 'nightly'
      shell 'cat /etc/yum.repos.d/foreman.repo' do |r|
        r.stdout =~ %r{^baseurl=.*/nightly/}
      end
    elsif node.facts['osfamily'] == 'Debian'
      foreman_installer_install :repo => 'stable'  # no other repo has foreman-installer
      shell 'cat /etc/apt/sources.list.d/foreman.list' do |r|
        r.stdout.include? ' stable '
      end
    end
    shell 'test -d /usr/share/foreman-installer/foreman' do |r|
      r.exit_code.should == 0
    end
  end

  it 'should install from installer_source option' do
    Dir.mktmpdir do |source|
      File.open("#{source}/test", "w") { |f| f.write("test") }
      foreman_installer_install :installer_source => source
      if node.facts['osfamily'] == 'RedHat'
        shell 'test -e /etc/yum.repos.d/foreman.repo' do |r|
          r.exit_code.should == 1
        end
      elsif node.facts['osfamily'] == 'Debian'
        shell 'test -e /etc/apt/sources.list.d/foreman.list' do |r|
          r.exit_code.should == 1
        end
      end
      shell 'cat /usr/share/foreman-installer/test' do |r|
        r.stdout.should == 'test'
      end
    end
  end

  it 'should configure repo from custom_repo option' do
    pending 'only supported with yum', :unless => (node.facts['osfamily'] == 'RedHat')
    repo = 'http://yum.theforeman.org/releases/latest/el6/x86_64/'
    foreman_installer_install :custom_repo => repo
    shell 'cat /etc/yum.repos.d/foreman.repo' do |r|
      r.stdout.should =~ /^name=.*custom/
      r.stdout.should =~ /^baseurl=#{repo}/
      r.stdout.should =~ /^gpgcheck=0/
    end
    shell 'test -d /usr/share/foreman-installer/foreman' do |r|
      r.exit_code.should == 0
    end
  end

  it 'should install foreman-release from release_url option' do
    pending 'only supported with yum', :unless => (node.facts['osfamily'] == 'RedHat')
    foreman_installer_install :release_url => 'http://yum.theforeman.org/releases/latest/el6/x86_64/foreman-release.rpm'
    shell 'cat /etc/yum.repos.d/foreman.repo' do |r|
      r.stdout.should =~ /^name=.*Foreman/i
    end
    shell 'rpm -q foreman-release' do |r|
      r.exit_code.should == 0
    end
    shell 'test -d /usr/share/foreman-installer/foreman' do |r|
      r.exit_code.should == 0
    end
  end
end
