require 'mongoid'

raise "Unable to load mongoid" unless Mongoid.load!(File.expand_path('../../config/mongoid.yml', __FILE__), :development)

module SmartHome
  module Weather
    class Source
      include Mongoid::Document

      field :name, type: String

      has_many :observations
    end

    class WeatherStation
      include Mongoid::Document
      include Mongoid::Timestamps

      field :name, type: String
      field :location, type: Array
      field :stno, type: Integer
      field :url, type: String

      has_many :observations
    end

    class Observation
      include Mongoid::Document

      field :time, type: DateTime

      index({time: 1, source: 1}, {unique: true})

      belongs_to :source
      belongs_to :weather_station
    end

    class Temperature < Observation
      validates_uniqueness_of :time, scope: :weather_station

      field :value, type: Float
    end

    class Wind < Observation
      validates_uniqueness_of :time, scope: :weather_station

      field :direction, type: Integer
      field :speed, type: Float
    end
  end
end
