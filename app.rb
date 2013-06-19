require 'sinatra/base'
require "sinatra/reloader"

require 'nokogiri'
require 'open-uri'
require 'json'

require_relative './models/weather'
require_relative './models/power'

module SmartHome
  extend self

  class App < Sinatra::Base
    configure :development do
      register Sinatra::Reloader
    end


    get '/' do
      #Weather::Observation.all.to_json
      erb :index
    end

    get '/power_reading' do
      "Hello world"
    end

    post '/power_reading' do
      if params['value'] && params['time']
        Power::PowerReading.create(value: params['value'], created_at: params['time'])
      elsif params['value']
        Power::PowerReading.create(value: params['value'])
      end
    end

    run! if __FILE__ == $0
  end
end
