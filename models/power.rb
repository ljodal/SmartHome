require 'mongoid'

module SmartHome
  module Power
    class PowerReading
      include Mongoid::Document
      include Mongoid::Timestamps::Created

      validates :value, presence: true

      field :value, type: Integer
    end
  end
end
