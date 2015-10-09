require 'rails_helper'

RSpec.describe SamlController do

  describe "POST login" do
    let(:user) { FactoryGirl.create(:user, last_portal_visited: family_account_path)}

    invalid_xml = File.read("spec/saml/invalid_saml_response.xml")

    context "with devise session active" do
      it "should sign out current user" do
        sign_in user
        expect(subject).to receive(:sign_out).with(user)
        post :login, :SAMLResponse => invalid_xml
      end
    end

    context "with invalid saml response" do

      it "should render a 403" do
        expect(subject).to receive(:log) do |arg1, arg2|
          expect(arg1).to match(/ERROR: SAMLResponse assertion errors/)
          expect(arg2).to eq(:severity => 'error')
        end
        post :login, :SAMLResponse => invalid_xml
        expect(response).to render_template(:file => "#{Rails.root}/public/403.html")
        expect(response).to have_http_status(403)
      end
    end

    context "with valid saml response" do
      sample_xml = File.read("spec/saml/invalid_saml_response.xml")
      let(:name_id) { user.email}
      let(:valid_saml_response) { double(is_valid?: true, :"settings=" => true, attributes: attributes_double, name_id: name_id)}
      let(:attributes_double) { { 'mail' => user.email} }

      before do
        allow(OneLogin::RubySaml::Response).to receive(:new).and_return( valid_saml_response )
      end

      describe "with an existing user" do
        it "should redirect back to their last portal" do
          post :login, :SAMLResponse => sample_xml
          expect(response).to redirect_to(user.last_portal_visited)
          expect(flash[:notice]).to eq "Signed in Successfully."
          expect(User.where(email: user.email).first.oim_id).to eq name_id
          expect(User.where(email: user.email).first.idp_verified).to be_truthy
        end
      end

      describe "with a new user" do
        let(:name_id) { attributes_double['mail'] }
        let(:attributes_double) { { 'mail' => "new@user.com"} }

        it "should claim the invitation" do
          post :login, :SAMLResponse => sample_xml
          expect(response).to redirect_to(search_insured_consumer_role_index_path)
          expect(flash[:notice]).to eq "Signed in Successfully."
          expect(User.where(email: attributes_double['mail']).first.oim_id).to eq name_id
          expect(User.where(email: attributes_double['mail']).first.idp_verified).to be_truthy
        end
      end
    end
  end
end