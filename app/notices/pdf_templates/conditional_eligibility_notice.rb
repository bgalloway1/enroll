module PdfTemplates
  class ConditionalEligibilityNotice
    include Virtus.model

    attribute :primary_fullname, String
    attribute :primary_identifier, String
    attribute :notice_date, Date
    attribute :primary_address, PdfTemplates::NoticeAddress
    attribute :enrollments, Array[PdfTemplates::Enrollment]
    attribute :individuals, Array[PdfTemplates::Individual]

    def other_enrollments
      enrollments.reject{|enrollment| enrollments.index(enrollment).zero? }
    end

    def shop?
      false
    end

    def verified_individuals
      individuals.select{|individual| individual.verified }
    end

    def unverified_individuals
      individuals.reject{|individual| individual.verified }
    end

    def ssn_unverified
      individuals.reject{|individual| individual.ssn_verified}
    end

    def citizenship_unverified
      individuals.reject{|individual| individual.citizenship_verified}
    end

    def residency_unverified
      individuals.reject{|individual| individual.residency_verified}
    end

    def indian_conflict
      individuals.select{|individual| individual.indian_conflict}
    end
  end
end