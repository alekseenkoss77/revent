$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
ENV["RACK_ENV"] ||= 'test'

require 'revent'
require 'pry-byebug'
require 'bunny-mock'

BunnyMock::use_bunny_queue_pop_api = true

RSpec.configure do |config|
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
end
