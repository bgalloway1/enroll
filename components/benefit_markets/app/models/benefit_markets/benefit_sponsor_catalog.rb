module BenefitMarkets
  class BenefitSponsorCatalog
    include Mongoid::Document
    include Mongoid::Timestamps

    embedded_in :benefit_application, class_name: "::BenefitSponsors::BenefitApplications::BenefitApplication"

    field :effective_date,    type: Date 
    field :probation_period_kinds, type: Array, default: []
    field :service_area_id

    embeds_one  :sponsor_market_policy,  
                class_name: "::BenefitMarkets::MarketPolicies::SponsorMarketPolicy"
    embeds_one  :member_market_policy,
                class_name: "::BenefitMarkets::MarketPolicies::MemberMarketPolicy"
    embeds_many :product_packages, as: :catalogable,
                class_name: "::BenefitMarkets::Products::ProductPackage"


    def product_market_kind
      "shop"
    end
    
    def product_active_year
      benefit_application.effective_period.begin.year
    end
  end
end
