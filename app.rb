require 'sinatra/base'
require "sinatra/reloader"

require 'nokogiri'
require 'open-uri'
require 'json'

require_relative './models/weather'

module SmartHome
  extend self

  class App < Sinatra::Base
    configure :development do
      register Sinatra::Reloader
    end


    get '/' do
      Weather::Observation.all.to_json
    end

    run! if __FILE__ == $0
  end
end
