require 'nokogiri'
require 'open-uri'
require 'json'
require 'date'

require_relative './models/weather'

module SmartHome
  def self.get_weather
    Weather::WeatherStation.each do |station|
      doc = Nokogiri::XML(open(URI::encode(station.url)))
      observations = doc.xpath("//observations/weatherstation[@stno=#{station.stno}]")
      temp = observations.xpath("temperature").first
      windSpeed = observations.xpath("windSpeed").first
      windDir = observations.xpath("windDirection").first

      if temp
        o = station.observations.create({value: temp["value"], time: DateTime.parse(temp["time"])}, Weather::Temperature)
        puts o.valid?
      end

      if windSpeed && windDir && windSpeed["time"] == windDir["time"]
        o = station.observations.create({direction: windDir["deg"], speed: windSpeed["mps"], time: DateTime.parse(windDir["time"])}, Weather::Wind)
        puts o.valid?
      end
    end
  end

  get_weather if $0 == __FILE__
end
