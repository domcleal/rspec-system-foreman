source 'https://rubygems.org'

gemspec

# pending: https://github.com/puppetlabs/rspec-system-puppet/pull/12
gem 'rspec-system-puppet', :git => 'git://github.com/domcleal/rspec-system-puppet.git', :branch => 'apply-module-path'

group :development, :test do
  gem 'rake'
  gem 'mocha', :require => 'mocha/api'
end

group :development do
  gem 'yard'
  gem 'redcarpet'
end
