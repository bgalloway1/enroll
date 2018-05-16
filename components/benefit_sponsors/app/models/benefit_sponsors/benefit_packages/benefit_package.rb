module BenefitSponsors
  module BenefitPackages
    class BenefitPackage
      include Mongoid::Document
      include Mongoid::Timestamps
    

      embedded_in :benefit_application, class_name: "BenefitSponsors::BenefitApplications::BenefitApplication"

      field :title, type: String, default: ""
      field :description, type: String, default: ""
      field :probation_period_kind, type: Symbol
      field :is_default, type: Boolean, default: false

      # Deprecated: replaced by FEHB profile and FEHB market
      # field :is_congress, type: Boolean, default: false

      embeds_many :sponsored_benefits,
                  class_name: "BenefitSponsors::SponsoredBenefits::SponsoredBenefit"

      delegate :benefit_sponsor_catalog, to: :benefit_application

      delegate :rate_schedule_date, to: :benefit_application

      # # Length of time New Hire must wait before coverage effective date
      # field :probation_period, type: Range
 

      # # The date range when this application is active
      # field :effective_period,        type: Range

      # # The date range when all members may enroll in benefit products
      # field :open_enrollment_period,  type: Range


      # calculate effective on date based on probation period kind
      # Logic to deal with hired_on and created_at
      # returns a roster
      def new_hire_effective_on(roster)
        
      end

      # TODO: there can be only one sponsored benefit of each kind
      def add_sponsored_benefit(new_sponsored_benefit)
        sponsored_benefits << new_sponsored_benefit
      end

      def drop_sponsored_benefit(sponsored_benefit)
        sponsored_benefits.delete(sponsored_benefit)
      end

      def renew(new_benefit_package)
        new_benefit_package.assign_attributes({
          title: title,
          description: description,
          probation_period_kind: probation_period_kind,
          is_default: is_default
        })
        
        sponsored_benefits.each do |sponsored_benefit|

          new_benefit_sponsor_catalog = new_benefit_package.benefit_sponsor_catalog
          new_product_package = new_benefit_sponsor_catalog.product_packages
                  .by_kind(sponsored_benefit.product_package_kind)
                  .by_product_kind(sponsored_benefit.product_kind)[0]


          if new_product_package.present?
            reference_product = sponsored_benefit.reference_product
            if reference_product && reference_product.renewal_product.present?

              # product_package = sponsored_benefit.product_package
              # renewal_products = product_package.active_products.collect{|product| product.renewal_product}.compact

              # if renewal_products.present? && (new_product_package.products & renewal_products).any?
              new_sponsored_benefit = sponsored_benefit.renew(new_product_package)
              new_benefit_package.add_sponsored_benefit(new_sponsored_benefit)
              # end
            end
          end
        end

        new_benefit_package
      end

      def build_relationship_benefits
      end

      def build_dental_relationship_benefits
      end

      def self.transform_to_sponsored_benefit_template(product_package)
        sponsored_benefit = TransformProductPackageToSponsoredBenefit.new(product_package).transform
      end

      def set_sponsor_choices(sponsored_benefit)
        # trigger composite

      end

      def sponsored_benefits=(sponsored_benefits_attrs)
        sponsored_benefits_attrs.each do |sponsored_benefit_attrs|
          sponsored_benefit = sponsored_benefits.build
          sponsored_benefit.assign_attributes(sponsored_benefit_attrs)
        end
      end
    end
  end
end
