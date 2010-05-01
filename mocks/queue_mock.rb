require 'rubygems'
require 'sinatra'
require 'json'

get '/queue' do
  {:status => rand(100)}.to_json
end
