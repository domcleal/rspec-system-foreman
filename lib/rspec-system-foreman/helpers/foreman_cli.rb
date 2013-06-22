require 'rspec-system'
require 'json'

module RSpecSystem::Helpers
  class ForemanCli < RSpecSystem::Helper
    name 'foreman_cli'
    properties :output

    def initialize(opts, clr, &block)
      ns = rspec_system_node_set
      opts = {
        :user => 'admin',
        :password => 'changeme',
        :n => ns.default_node,
      }.merge(opts)

      opts[:url] ||= "https://#{opts[:n]}"

      super(opts, clr, &block)
    end

    def execute
      facts = node.facts
      cmd = opts[:command] || opts[:c]
      clicmd = "foremancli -s #{opts[:url]} -u #{opts[:user]} -p #{opts[:password]} --json #{cmd}"

      if facts['osfamily'] == 'RedHat' && facts['operatingsystem'] != 'Fedora'
        # why no binstubs?
        clicmd = "scl enable ruby193 '/opt/rh/ruby193/root/usr/local/share/gems/gems/foremancli-1.0/bin/#{clicmd}'"
      end

      log.info("running foremancli #{cmd}")
      json = nil
      shell :c => clicmd do |r|
        raise "foremancli failed: #{r.stdout} / #{r.stderr}" unless r.exit_code == 0
        json = JSON.parse(r.stdout)
      end

      {:output => json}
    end
  end
end
