require 'nest_thermostat'

module Lita
  module Handlers
    class Nest < Handler
      config :email, type: String, required: true
      config :password, type: String, required: true

      route(/^nest\s+temp(erature)?$/i, :get_temp, help: { "nest temp" => "Gets the current room temperature" })
      route(/^nest\s+target\s+temp(erature)?$/i, :get_target, help: { "nest target temp" => "Gets the current target temperature" })
      route(/^nest\s+set\s+target\s+temp(erature)?\s+(\d+(\.\d+)?)/i, :set_target, help: { "nest set target temp" => "Sets the target temperature" })
      route(/^nest\s+set\s+away\s+(on|off)/i, :set_away, help: { "nest set away (on|off)" => "Set Away" })
      route(/^nest\s+away/i, :get_away, help: { "nest away" => "Report away status" })

      def nest
        @@nest = NestThermostat::Nest.new({ email: config.email, password: config.password, temperature_scale: 'c' }) if @@nest.nil?
        @@nest
      end

      def get_temp(response)
        response.reply "Room temperature is #{nest.current_temperature.round(1)}"
      end

      def get_target(response)
        response.reply "Target temperature is #{nest.temperature.round(1)}"
      end

      def set_target(response)
        temp = response.matches[0][1].to_f
        nest.temp = temp
        response.reply "Target temperature set to #{temp}"
      end

      def set_away(response)
        set=(response.matches[0][0].downcase == "on") ? true : false
        nest.away = set
        response.reply "Nest Away set to #{set}"
      end

      def get_away(response)
        response.reply "Nest away is #{nest.away ? 'on' : 'off'}"
      end

      @@nest = nil

    end

    Lita.register_handler(Nest)
  end
end
