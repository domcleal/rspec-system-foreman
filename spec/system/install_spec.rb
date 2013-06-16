require 'spec_helper_system'

describe 'foreman_install' do
  before :all do
    foreman_installer_install
  end

  before :each do
    # Cleanup
    if node.facts['osfamily'] == 'RedHat'
      shell 'yum --disablerepo=\* --enablerepo=epel\* clean all'
      shell 'rpm -e epel-release'
      shell 'rm -rf /etc/foreman-installer'
    elsif node.facts['osfamily'] == 'Debian'
      shell 'rm -rf /etc/foreman-installer'
    end

    # Don't really install
    RSpecSystemPuppet::Helpers::PuppetApply.any_instance.stub(:execute)
  end

  it 'should install EPEL only on EL' do
    foreman_install
    if node.facts['osfamily'] == 'RedHat'
      shell 'rpm -q epel-release' do |r|
        r.exit_code.should == (node.facts['operatingsystem'] == 'Fedora' ? 1 : 0)
      end
    end
  end

  it 'should create answers file' do
    foreman_install
    shell 'cat /etc/foreman-installer/answers.yaml' do |r|
      r.exit_code.should == 0
      y = YAML.load(r.stdout)
      y['foreman'].should == true
      y['foreman_proxy'].should == true
      y['puppet'].should == true
      y['puppetmaster'].should == true
    end
  end

  context 'answers option' do
    it 'should override with false options' do
      foreman_install :answers => { :foreman_proxy => false }
      shell 'cat /etc/foreman-installer/answers.yaml' do |r|
        r.exit_code.should == 0
        y = YAML.load(r.stdout)
        y['foreman'].should == true
        y['foreman_proxy'].should == false
        y['puppet'].should == true
        y['puppetmaster'].should == true
      end
    end

    it 'should override with true options' do
      shell :c => 'cp /usr/share/foreman-installer/foreman_installer/answers.yaml /usr/share/foreman-installer/foreman_installer/answers.yaml.bak', :d => node
      begin
        file = Tempfile.new 'answers'
        begin
          file.write("--- \nforeman: false\n")
          file.close
          rcp :sp => file.path, :dp => '/usr/share/foreman-installer/foreman_installer/answers.yaml', :d => node
        ensure
          file.unlink
        end
        foreman_install :answers => { :foreman => true }
        shell 'cat /etc/foreman-installer/answers.yaml' do |r|
          r.exit_code.should == 0
          y = YAML.load(r.stdout)
          y['foreman'].should == true
        end
      ensure
        shell :c => 'cp /usr/share/foreman-installer/foreman_installer/answers.yaml.bak /usr/share/foreman-installer/foreman_installer/answers.yaml', :d => node
      end
    end

    it 'should override with hashes' do
      foreman_install :answers => { :foreman => { :b => 'c' } }
      shell 'cat /etc/foreman-installer/answers.yaml' do |r|
        r.exit_code.should == 0
        y = YAML.load(r.stdout)
        y['foreman'].should == { 'b' => 'c' }
        y['foreman_proxy'].should == true
        y['puppet'].should == true
        y['puppetmaster'].should == true
      end
    end

    it 'should merge hashes' do
      shell :c => 'cp /usr/share/foreman-installer/foreman_installer/answers.yaml /usr/share/foreman-installer/foreman_installer/answers.yaml.bak', :d => node
      begin
        file = Tempfile.new 'answers'
        begin
          file.write("--- \nforeman:\n  a: b\n  b: c\n")
          file.close
          rcp :sp => file.path, :dp => '/usr/share/foreman-installer/foreman_installer/answers.yaml', :d => node
        ensure
          file.unlink
        end
        foreman_install :answers => { :foreman => { :b => 'a', :c => 'c' } }
        shell 'cat /etc/foreman-installer/answers.yaml' do |r|
          r.exit_code.should == 0
          y = YAML.load(r.stdout)
          y['foreman'].should == { 'a' => 'b', 'b' => 'a', 'c' => 'c' }
        end
      ensure
        shell :c => 'cp /usr/share/foreman-installer/foreman_installer/answers.yaml.bak /usr/share/foreman-installer/foreman_installer/answers.yaml', :d => node
      end
    end
  end
end
