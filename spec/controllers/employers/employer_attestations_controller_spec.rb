require 'rails_helper'

RSpec.describe Employers::EmployerAttestationsController do


  describe "GET edit" do
    let(:user) { FactoryBot.create(:user) }
    let(:employer_profile) { FactoryBot.create(:employer_profile) }

    it "should render the edit template" do
      allow(user).to receive(:has_hbx_staff_role?).and_return(true)
      sign_in(user)
      get :edit, params: {id: employer_profile.id}, xhr: true
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET new" do
    let(:user) { FactoryBot.create(:user) }

    it "should render the edit template" do
      sign_in(user)
      get :new, xhr: true
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST create" do
    let(:user) { FactoryBot.create(:user) }
    let(:tempfile) { double(path: 'tmp/sample.pdf') }
    let(:file) { double(original_filename: 'sample.pdf', size: 400, tempfile: tempfile) }
    let(:employer_profile) { FactoryBot.create(:employer_profile) }

    before do 
      allow(controller).to receive(:params).and_return({id: employer_profile.id, file: file})
      allow(Aws::S3Storage).to receive(:save).and_return(doc_uri)

      sign_in(user)
      post :create, params: {id: employer_profile.id}
    end

    context 'when file upload failed' do
      let(:doc_uri) { nil } 

      it "should render the edit template" do
        expect(flash[:error]).to eq "Could not save the file in S3 storage"
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'when file upload successful' do
      let(:doc_uri) { "urn:openhbx:terms:v1:file_storage:s3:bucket" }

      it 'should return success' do
        employer_profile.reload
        expect(employer_profile.employer_attestation.aasm_state).to eq "submitted"
        expect(employer_profile.employer_attestation.employer_attestation_documents.first.aasm_state).to eq "submitted"
        expect(flash[:notice]).to eq "File Saved"
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe "PUT update" do 
    let(:user) { FactoryBot.create(:user) }
    let(:attestation_doc) { FactoryBot.create(:employer_attestation_document) }

    it "should render the edit template" do
      allow(user).to receive(:has_hbx_staff_role?).and_return(true)
      allow(attestation_doc).to receive(:submit_review).and_return(true)

      sign_in(user)
      put :update, params: {id: attestation_doc.employer_profile.id, employer_attestation_id: attestation_doc.id, status: 'accepted'}

      expect(flash[:notice]).to eq "Employer attestation updated successfully"
      expect(response).to have_http_status(:redirect)
    end
  end
end
