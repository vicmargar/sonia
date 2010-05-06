require "eventmachine"
require "em-websocket"
require 'em-http'
require "yajl"
require "yaml"
require "thin"

if RUBY_VERSION >= "1.9.0"
  module EventMachine
    module WebSocket
      class Connection < EventMachine::Connection
        def send(data)
          debug [:send, data]
          send_data("\x00#{data.force_encoding(Encoding::ASCII_8BIT)}\xff")
        end
      end
    end
  end
end

module Sonia
  # Main Sonia event loop
  #
  # Starts both WebServer and WebSocket server
  #
  # @author Piotr Usewicz
  module Server
    extend self

    WEBSOCKET_HOST = "localhost"
    WEBSOCKET_PORT = 8080

    WEBSERVER_HOST = "localhost"
    WEBSERVER_PORT = 3000

    COMMANDSERVER_HOST = "localhost"
    COMMANDSERVER_PORT = 3001

    # Starts the server
    #
    # @param [Hash] args Startup options
    def run!(args, &block)
      @start_block = block
      configure(args)
      serve
    end

    # Returns configuration from the config file
    #
    # @return [Config]
    def config
      @@config
    end

    # Loads the configuration file
    #
    # @param [Hash] options
    # @return [Config]
    def configure(options)
      @@config = Config.new(YAML.load_file(File.expand_path(options.config)))
    end

    # Returns [Logger] object
    #
    # @return [Logger]
    def log
      Sonia.log
    end

    # Starts main [EventMachine] loop
    def serve
      EventMachine.run {
        Sonia.initialize_command_queue
        initialize_widgets
        start_web_socket_server
        start_web_server
        start_command_server
        EventMachine::add_periodic_timer( 1 ) { process_command_queue }
        @start_block.call
      }
    end

    # Goes through configured widgets and initializes them
    def initialize_widgets
      @widgets = []

      config.each do |widget, config|
        class_name = "Sonia::Widgets::#{widget.to_s}"
        log.info("Server") { "Created widget #{widget} with #{config.inspect}" }
        @widgets << module_eval(class_name).new(config)
      end
    end

    # Returns websocket configuration options
    #
    # @return [Hash] Websocket's host and port number
    def websocket_options
      { :host => WEBSOCKET_HOST, :port => WEBSOCKET_PORT }
    end

    # Starts WebSocket server
    def start_web_socket_server
      EventMachine::WebSocket.start(websocket_options) do |ws|
        @command_channel = EM::Channel.new
        @command_channel.subscribe { |msg| ws.send msg }
        ws.onopen {

          log.info("Opened connection from: #{ws}")

          @widgets.map { |widget| widget.subscribe!(ws) }

          setup_message = { :setup => @widgets.map { |widget| widget.setup } }
          ws.send Yajl::Encoder.encode(setup_message)

          log.info("Server") { "Sent setup #{setup_message.inspect}" }

          @widgets.each { |widget|
            if widget.respond_to?(:initial_push)
              log.info(widget.widget_name) { "Sending initial push" }
              widget.initial_push
            end
          }
        }

        ws.onmessage{ |msg|
          log.info("Received message: #{msg}")
        }

        ws.onclose {
          @widgets.each { |widget| widget.unsubscribe! }
        }
      end
      log.info("Server") { "WebSocket Server running at #{websocket_options[:host]}:#{websocket_options[:port]}" }
    end

    def process_command_queue
      Sonia.command_queue.pop{ |command|
        log.info("Popped command: #{command.inspect}")
        @command_channel.push(build_command(command))
      }
    end

    def build_command(command)
      Yajl::Encoder.encode({:command => command})
    end

    # Starts Thin WebServer
    def start_web_server
      Thin::Server.start(WEBSERVER_HOST, WEBSERVER_PORT, ::Sonia::WebServer)
    end

    # Starts Thin Command Server
    def start_command_server
      Thin::Server.start(COMMANDSERVER_HOST, COMMANDSERVER_PORT, ::Sonia::CommandServer)
    end

    # Returns WebServer URL
    #
    # @return [String] WebServer URL
    def webserver_url
      "http://#{WEBSERVER_HOST}:#{WEBSERVER_PORT}"
    end
  end
end
