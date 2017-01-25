require 'anyway'

module Revent
  class Config < Anyway::Config
    attr_config provider: 'RabbitMQ',
                host: 'localhost',
                port: '5672',
                username: 'guest',
                password: 'guest'
  end
end