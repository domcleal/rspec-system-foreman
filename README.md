# rspec-system-foreman

`rspec-system-foreman` is a plugin for [rspec-system](https://rubygems.org/gems/rspec-system) that can install and configure [Foreman](http://theforeman.org) using the [Foreman installer](https://github.com/theforeman/foreman-installer) Puppet modules.

Its primary use is testing the Foreman installer and new Foreman packages, but it might also be useful to plugin authors or users wanting a functional Foreman instance to test with.

The module is based on, and extends, [rspec-system-puppet](https://github.com/puppetlabs/rspec-system-puppet).  Check the docs there for good instructions on setting it up.

## Prefabs

The prefabs are currently pointing to boxes built for libvirt (KVM), but are intended to be entirely compatible with [the standardised prefabs](https://github.com/puppetlabs/rspec-system#prefabs) used for rspec-system.
