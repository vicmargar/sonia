require 'sinatra'

module Sonia
  # Sonia's Command Server
  #
  # Allows dynamically generating HTML pages
  #
  # @author Victor Martinez
  class CommandServer < Sinatra::Base

    # Config methods
    get "/command" do
      Sonia.command_queue.push params
      "Thanks for your command: #{params}"
    end

  end
end
