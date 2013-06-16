require 'rspec-system/spec_helper'
require 'rspec-system-foreman/helpers'

include RSpecSystemForeman::Helpers
RSpec.configure do |c|
  c.include RSpecSystemForeman::Helpers
end
