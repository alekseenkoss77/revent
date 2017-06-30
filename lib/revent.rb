require "revent/version"
require "revent/config"
require 'active_support'
require 'active_support/core_ext'

require 'revent/providers/rabbit_mq'

module Revent
  def self.config
    @config ||= Config.new
  end

  def self.configure
    yield(config) if block_given?
  end

  def self.publish(event_name, payload = {})
    ActiveSupport::Notifications.instrument(event_name, payload) { yield if block_given? }
  end

  def self.subscribe(event_name, callback = nil)
    ActiveSupport::Notifications.subscribe(event_name) do |name, start, ending, transaction_id, payload|
      next unless payload.present?
      
      event = ActiveSupport::Notifications::Event.new(name, start, ending, transaction_id, payload)
      
      if block_given?
        yield(event)
      elsif callback.present? && callback.is_a?(Proc)
        callback.call(event)
      end
      
      # Emit event to external provider if exists
      event_provider.emit(event) if event_provider.present?
    end
  end

  def self.event_provider
    return unless config.provider.present?
    "Revent::Providers::#{config.provider}".safe_constantize
  end
end
