require 'em-http'

module Sonia
  module Widgets
    class LineGraph < Sonia::Widget
      def initialize(config)
        super(config)
        EventMachine::add_periodic_timer(2) { fetch_data }
      end

      def initial_push
        fetch_data
      end

      def format_status(status)
        {
          :time => Time.now.to_s,
          :value => status["status"]
        }
      end

      private
      def fetch_data
        log_info "Polling `#{service_url}'"
        http = EventMachine::HttpRequest.new(service_url).get
        http.errback { log_fatal_error(http) }
        http.callback {
          handle_fetch_data_response(http)
        }
      end

      def handle_fetch_data_response(http)
        if http.response_header.status == 200
          parse_response(http.response)
        else
          log_unsuccessful_response_body(http.response)
        end
      end

      def parse_response(response)
        status = parse_json(response)
        push format_status(status)
      rescue => e
        log_backtrace(e)
      end

      def service_url
        config[:url]
      end
    end
  end
end
