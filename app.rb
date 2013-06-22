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

    get '/blocks' do
      erb :blocks
    end

    get %r{/weather/(\d+)(\..*)?} do |hours, ext|
      @stations = [];
      Weather::WeatherStation.each do |s|
        station = {}
        station[:name] = s.name
        station[:observations] = s.observations.exists(value: true).where(:time.gte => DateTime.now - hours.to_i.hours).desc(:time)
        @stations << station
      end

      if ext == ".json"
        @stations.to_json
      else
        "HTML"
      end
    end

    get '/power' do
      first = Power::PowerReading.asc(:created_at).first
      last = Power::PowerReading.desc(:created_at).first

      total = last.value - first.value
      days = (last.created_at - first.created_at) / 1.day

      avg = total / days

      "Avg. power consumption pr. day: #{avg}"
    end

    get '/power_reading/last' do
      Power::PowerReading.desc(:created_at).limit(10).to_json
    end

    get '/power_reading/first' do
      Power::PowerReading.asc(:created_at).limit(10).to_json
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

    get '/finn.no' do
      xpath = '//div[@id="resultList"]//div[contains(@class, "r-object media")]/div[contains(@class, "bd")]/div[contains(@class, "objectinfo")]'

      url = "http://www.finn.no/finn/torget/resultat?keyword=686&SEGMENT=0&ITEM_CONDITION=0&SEARCHKEYNAV=SEARCH_ID_BAP_ALL&categories=93%3A3906%3A53&sort=5&periode="

      doc = Nokogiri::HTML(open(url))

      results = []

      doc.xpath(xpath).each do |item|
        top = item.xpath('div[@class = "line"]/h2/a').first
        title = top.text
        url = "http://www.finn.no/finn/torget/"+top["href"]

        results << {title: title, url: url}
      end

      results.to_json
    end
  end
end
