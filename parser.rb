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

  def self.debug_weather
    type = 2
    stations = SmartHome::Weather::WeatherStation.all.map {|s| s.stno }
    start_date = DateTime.parse("2013-06-01")
    stop_date = DateTime.parse("2013-06-30")
    elements = ["TAX", "TAN", "TA","RR_01", "RR_1","RR"]
    hours = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]


#   Weather::WeatherStation.each do |station|
      url = "http://eklima.met.no/met/MetService?invoke=getMetData&timeserietypeID=#{type}&format=&from=2013-06-18&to=2013-06-20&stations=#{stations.join(",")}&elements=#{elements.join(',')}&hours=#{hours.join(',')}&months=&username="
      doc = Nokogiri::XML(open(url))
      doc.xpath("//timeStamp/item").each do |observation|
        date_time = DateTime.parse(observation.xpath("from").text)
        observation.xpath("location/item").each do |observations|
          station_id =  observations.xpath("id").text
          station = Weather::WeatherStation.where(stno: station_id).first
          observations.xpath("weatherElement/item").each do |item|
            case item.xpath("id").text
            when "TA"
              puts "Temperature at #{station.name} at #{date_time}: " + item.xpath("value").text
            else
              puts item.xpath("value").text
            end
          end
        end
      end
#    end

  end

  debug_weather if $0 == __FILE__
end
