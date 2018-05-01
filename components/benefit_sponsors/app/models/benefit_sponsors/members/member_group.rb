# A collection of members, typically a family, who operate as a unit for purposes of benefit coverage
module BenefitSponsors
  class Members::MemberGroup
    include Enumerable
    include ActiveModel::Model

    attr_accessor :members, :group_id, :group_enrollment

    def initialize(opts = {})
      @members          = []
      @group_id         = nil
      @group_enrollment = nil
      super(opts)
    end

    def primary_member
      @members.detect { |member| member.is_primary_member? }
    end

    def add_member(new_member)
      @members << new_member unless is_duplicate_role?(new_member)
    end

    def drop_member(member)
      @members.delete(member)
    end

    def <<(new_member)
      add_member(new_member)
    end

    def [](index)
      @members = index.each { |new_member| add_member(new_member) unless is_duplicate_role?(new_member) }
    end

    def []=(index, new_member)
      @members[index] = new_member unless is_duplicate_role?(new_member)
    end


    private

    def has_primary_member?
      @members.detect { |member| member.is_primary_member? }
    end

    def has_spouse_relationship?
      @members.detect { |member| member.is_spouse_relationship? }
    end

    def has_survivor_member?
      @members.detect { |member| member.is_survivor_member? }
    end

    def is_duplicate_role?(new_member)
      if new_member.is_primary_member? && has_primary_member?
        raise DuplicatePrimaryMemberError, "may have only one primary member"
      end

      if new_member.is_spouse_relationship? && has_spouse_relationship?
        raise MultipleSpouseRelationshipError, "primary member may have only one spouse relationship"
      end

      false
    end

  end

  class DuplicatePrimaryMemberError < StandardError; end
  class MultipleSpouseRelationshipError < StandardError; end
end
