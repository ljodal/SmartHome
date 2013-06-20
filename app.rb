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
      erb :index
    end

    get %r{/weather/(\d+)(\..*)?} do |hours, ext|
      @stations = [];
      Weather::WeatherStation.each do |s|
        station = {}
        station[:name] = s.name
        station[:observations] = s.observations.exists(value: true).desc(:time).limit(hours.to_i+1)
        @stations << station
      end

      if ext == ".json"
        @stations.to_json
      else
        "HTML"
      end
    end

    get '/power_reading/last' do
      Power::PowerReading.desc(:created_at).first.to_json
    end

    get '/power_reading/first' do
      Power::PowerReading.asc(:created_at).first.to_json
    end

    get '/power_reading' do
      erb :power_reading
    end

    post '/power_reading' do
      if !params['value'].empty? && !params['time'].empty?
        Power::PowerReading.create(value: params['value'].to_i, created_at: DateTime.parse(params['time']))
      elsif !params['value'].empty?
        Power::PowerReading.create(value: params['value'].to_i)
      end
    end

    run! if __FILE__ == $0
  end
end
