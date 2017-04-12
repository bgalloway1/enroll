module Config::AcaModelConcern
  extend ActiveSupport::Concern

  included do
    delegate :aca_state_name, to: :class
    delegate :aca_state_abbreviation, to: :class
    delegate :individual_market_is_enabled?, to: :class
  end

  class_methods do
    def aca_state_abbreviation
      Settings.aca.state_abbreviation
    end

    def aca_state_name
      Settings.aca.state_name
    end

    def individual_market_is_enabled?
      @@individual_market_is_enabled ||= Settings.aca.market_kinds.include? "individual"
    end
  end
end
