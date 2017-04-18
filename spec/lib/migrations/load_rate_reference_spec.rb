require 'rails_helper'
require 'rake'
require 'roo'

RSpec.shared_examples "a rate reference" do |attributes|
  attributes.each do |attribute, value|
    it "should return #{value} from ##{attribute}" do
      expect(subject.send(attribute)).to eq(value)
    end
  end
end

RSpec.describe 'Load Rating Regions Task', :type => :task do

  context "rate_reference:update_rating_regions" do
    let(:file_path) { File.join(Rails.root,'lib', 'xls_templates', "SHOP_ZipCode_CY2017_FINAL.xlsx") }

    before :all do
      Rake.application.rake_require "tasks/migrations/load_rate_reference"
      Rake::Task.define_task(:environment)
    end

    before :context do
      invoke_task
    end

    context "it creates RateReference elements correctly" do
      subject { RateReference.first }
      it_should_behave_like "a rate reference", { zip_code: "01001",
                                                  county: "Hampden",
                                                  multiple_counties: false,
                                                  rating_region: "Rating Area 1"
                                                }
      # Which simply replaces all of these:
      #
      # it { is_expected.to have_attributes(zip_code: "01001") }
      # it { is_expected.to have_attributes(county: "Hampden") }
      # it { is_expected.to have_attributes(multiple_counties: false) }
      # it { is_expected.to have_attributes(rating_region: "Rating Area 1") }
      #
      # Which is just equilavent to a series of these:
      #
      # it "assigns the correct zip code" do
      #   expect(subject.zip_code).to eq('01001')
      # end
    end

    context "it handles the case where multiple counties exist in the same Zip Code" do
      let(:rate_references_by_zip) { RateReference.where(zip_code: "01002") }
      context "first rate reference for zip code" do
        subject { rate_references_by_zip.first }
        it_should_behave_like "a rate reference", { zip_code: "01002",
                                                    county: "Hampshire",
                                                    multiple_counties: true,
                                                    rating_region: "Rating Area 1"
                                                  }
      end

      context "second rate reference for zip code" do
        subject { rate_references_by_zip.second }
        it_should_behave_like "a rate reference", { zip_code: "01002",
                                                    county: "Franklin",
                                                    multiple_counties: true,
                                                    rating_region: "Rating Area 1"
                                                  }
      end
    end

    private

    def invoke_task
      Rake::Task["load_rate_reference:update_rating_regions"].invoke
    end
  end
end
