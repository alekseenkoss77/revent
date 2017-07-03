require 'revent'
require 'bunny'

module Revent
  module Providers
    class RabbitMQ
      attr_reader :conn, :channel, :queue, :params

      def initialize
        @params = {
          hostname: Revent.config.host,
          username: Revent.config.username,
          password: Revent.config.password
        }

        @queue = channel.queue('revent_queue', durable: true)
      end

      def publish(event)
        # transform ActiveSupport::Notifications::Event instance to json
        queue.publish(transform_event(event), persistent: true)
      end

      def conn
        @conn ||= initialize_client
      end

      def channel
        @channel ||= conn.create_channel
      end

      private

      def transform_event(event)
        return unless event.present?

        {
          event: event.name,
          started: event.time,
          finished: event.end,
          rails_transaction_id: event.transaction_id,
          payload: event.payload
        }.to_json
      end

      def initialize_client
        env = ENV['RAILS_ENV'] || ENV['RACK_ENV']
        
        if env == 'test'
          require 'bunny-mock'

          BunnyMock.new.start
        else
          Bunny.new(params).tap do |c|
            c.start
          end
        end
      end
    end
  end
end
