require 'rspec-system'

module RSpecSystem::Helpers
  class ForemanInstallerInstall < RSpecSystem::Helper
    name 'foreman_installer_install'

    def execute
      node = opts[:node]
      puppet_install opts

      facts = node.facts

      # Install the installer and optionally the repo
      if opts[:installer_source]
        log.info "Copying custom foreman-installer source checkout to /usr/share/foreman-installer"
        rcp :sp => opts[:installer_source], :dp => '/usr/share/foreman-installer'
      else
        if facts['osfamily'] == 'RedHat'
          if opts[:custom_repo]
            log.info "Installing custom yum repo from #{opts[:custom_repo]}"
            file = Tempfile.new('foreman.repo')
            begin
              file.write(<<EOS)
[foreman]
name=Foreman custom repo
baseurl=#{opts[:custom_repo]}
gpgcheck=0
EOS
              file.close
              rcp :sp => file.path, :dp => '/etc/yum.repos.d/foreman.repo', :d => node
            ensure
              file.unlink
            end
          else
            repo = case facts['operatingsystem']
            when 'Fedora'
              "f#{facts['operatingsystemrelease']}"
            else
              "el#{facts['operatingsystemrelease'][0]}"
            end
            opts[:release_url] ||= "http://yum.theforeman.org/#{opts[:repo] || 'releases/latest'}/#{repo}/#{facts['architecture']}/foreman-release.rpm"
            log.info "Installing release repo #{opts[:release_url]}"
            shell :c => "rpm -ivh #{opts[:release_url]}", :n => node
          end
          shell :c => 'yum -y install foreman-installer', :n => node
        elsif facts['osfamily'] == 'Debian'
          sources = "deb http://deb.theforeman.org/ #{facts['lsbdistcodename']} #{opts[:repo] || 'stable'}"
          log.info "Configuring sources: #{sources}"
          file = Tempfile.new('foreman.sources')
          begin
            file.write("#{sources}\n")
            file.close
            rcp :sp => file.path, :dp => '/etc/apt/sources.list.d/foreman.list', :d => node
          ensure
            file.unlink
          end
          shell :c => 'wget -q http://deb.theforeman.org/foreman.asc -O- | apt-key add -', :n => node
          shell :c => 'apt-get update && apt-get -y install foreman-installer', :n => node
        end
      end

      {}
    end
  end
end
