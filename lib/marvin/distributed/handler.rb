module Marvin
  module Distributed
    class Handler < Marvin::Base
      
      EVENT_WHITELIST = [:incoming_message, :incoming_action]
      QUEUE_PROCESSING_SPACING = 3
      
      attr_accessor :message_queue
      
      def initialize
        super
        @message_queue = []
      end
      
      def handle(message, options)
        return unless EVENT_WHITELIST.include?(message)
        super(message, options)
        dispatch(message, options)
      end
      
      def dispatch(name, options, client = self.client)
        return if client.blank?
        server = Marvin::Distributed::Server.next
        if server.blank?
          logger.debug "Distributed handler is currently busy - adding to queue"
          # TODO: Add to queued messages, wait
          @message_queue << [name, options, client]
          run! unless running?
        else
          server.dispatch(client, name, options)
        end
      rescue Exception => e
        logger.warn "Error dispatching #{name}"
        Marvin::ExceptionTracker.log(e)
      end
      
      def process_queue
        count = [@message_queue.size, Server.free_connections.size].min
        logger.debug "Processing #{count} item(s) from the message queue"
        count.times { |item| dispatch(*@message_queue.shift) }
        if @message_queue.empty?
          logger.debug "The message queue is now empty"
        else
          logger.debug "The message queue still has #{count} item(s)"
        end
        check_queue_progress
      end
      
      def running?
        @running_timer.present?
      end
      
      def run!
        @running_timer = EventMachine::PeriodicTimer.new(QUEUE_PROCESSING_SPACING) { process_queue }
      end
      
      def check_queue_progress
        if @message_queue.blank? && running?
          @running_timer.cancel
          @running_timer = nil
        elsif @message_queue.present? && !running?
          run!
        end
      end
      
      class << self
        
        def whitelist_event(name)
          EVENT_WHITELIST << name.to_sym
          EVENT_WHITELIST.uniq!
        end
        
        def register!(*args)
          # DO NOT register if this is  not a normal client.
          return unless Marvin::Loader.client?
          logger.info "Registering distributed handler on #{Marvin::Settings.client}"
          super
        end
        
      end
      
    end
  end
end