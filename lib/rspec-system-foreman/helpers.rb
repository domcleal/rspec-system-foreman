require 'rspec-system-foreman'
require 'rspec-system-puppet/helpers'
require 'rspec-system-foreman/helpers/foreman_install'
require 'rspec-system-foreman/helpers/foreman_installer_install'
require 'rspec-system-foreman/helpers/foreman_cli'

# This module contains the methods provide by rspec-system-foreman
module RSpecSystemForeman::Helpers
  include RSpecSystem::Helpers
  include RSpecSystemPuppet::Helpers

  # Installs the foreman-installer and optionally a repo
  #
  # @param opts [Hash] a hash of opts
  # @option opts [RSpecSystem::Node] :node node to execute DSL on
  # @option opts [String] :installer_source optional checkout of foreman-installer to use
  # @option opts [String] :release_url override URL of foreman-release RPM
  # @option opts [String] :custom_repo override URL of repo to install
  # @option opts [String] :repo sub-repo to use, default: latest stable release
  # @return [RSpecSystemForeman::Helpers::ForemanInstallerInstall] results
  # @yield [result] yields result when called as a block
  # @yieldparam result [RSpecSystem::Helpers::ForemanInstallerInstall] results
  def foreman_installer_install(opts = {}, &block)
    RSpecSystemForeman::Helpers::ForemanInstallerInstall.new(opts, self, &block)
  end

  # Basic helper to install Foreman with the installer
  #
  # @param opts [Hash] a hash of opts
  # @option opts [RSpecSystem::Node] :node node to execute DSL on
  # @option opts [Hash] :answers answers file hash, merged with defaults
  # @return [RSpecSystemForeman::Helpers::ForemanInstall] results
  # @yield [result] yields result when called as a block
  # @yieldparam result [RSpecSystem::Helpers::ForemanInstall] results
  def foreman_install(opts = {}, &block)
    RSpecSystemForeman::Helpers::ForemanInstall.new(opts, self, &block)
  end

  # Runs foremancli and returns the parsed result
  #
  # @param opts [Hash] a hash of opts
  # @option opts [RSpecSystem::Node] :node node to execute DSL on
  # @option opts [String] :url optional URL, defaults to https://node
  # @option opts [String] :user optional username, defaults to admin
  # @option opts [String] :password optional username, defaults to changeme
  # @option opts [String] :command arguments to foremancli
  # @return [RSpecSystemForeman::Helpers::ForemanCli] results
  # @yield [result] yields result when called as a block
  # @yieldparam result [RSpecSystem::Helpers::ForemanCli] results
  def foreman_cli(opts = {}, &block)
    RSpecSystemForeman::Helpers::ForemanCli.new(opts, self, &block)
  end
end
