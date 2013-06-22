require 'rspec-system'

module RSpecSystem::Helpers
  class ForemanInstall < RSpecSystem::Helper
    name 'foreman_install'

    def execute
      node = opts[:node]
      facts = node.facts

      if facts['osfamily'] == 'RedHat' && facts['operatingsystem'] != 'Fedora'
        log.info "Configuring EPEL"
        if facts['operatingsystemrelease'] =~ /^6\./
          shell :c => 'rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm', :n => node
        else
          shell :c => 'rpm -ivh http://dl.fedoraproject.org/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm', :n => node
        end
      end

      answers = {}
      shell :c => 'cat /usr/share/foreman-installer/foreman_installer/answers.yaml', :n => node do |r|
        answers = YAML.load(r.stdout)
      end
      # Merge user answers into defaults (can be booleans or hashes)
      if opts[:answers]
        opts[:answers].each do |k,v|
          k = k.to_s
          v = Hash[v.map {|k,v| [k.to_s, v] }] if v.is_a? Hash
          if (!v && answers[k]) || (v && !answers[k])  # invert override
            answers[k] = v
          elsif v.is_a?(Hash) && !answers[k].is_a?(Hash)  # override with options
            answers[k] = v
          elsif v.is_a?(Hash) && answers[k].is_a?(Hash)  # merge options
            answers[k].merge! v
          end
        end
      end

      log.info "Install answers file: #{answers.inspect}"
      shell :c => 'mkdir /etc/foreman-installer', :n => node
      file = Tempfile.new('answers')
      begin
        file.write(answers.to_yaml)
        file.close
        rcp :sp => file.path, :dp => '/etc/foreman-installer/answers.yaml', :d => node
      ensure
        file.unlink
      end

      # Run foreman-installer
      puppet_apply(:code => 'class { "foreman_installer": }', :n => node, :module_path => '/usr/share/foreman-installer') do |r|
        r.exit_code.should == 2
      end

      # Install foremancli
      cmd = 'gem install foremancli'
      cmd = "scl enable ruby193 '#{cmd}'" if facts['osfamily'] == 'RedHat' && facts['operatingsystem'] != 'Fedora'
      shell :c => cmd, :n => node do |r|
        r.exit_code.should == 0
      end

      {}
    end
  end
end
