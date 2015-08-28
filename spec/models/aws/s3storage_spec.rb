require 'rails_helper'

describe Aws::S3Storage do

  #allow(:storage_double) {double}
  #allow(Aws::S3Strorage).to receive(:new).and_respond_with(storage_double)
  let(:subject) { Aws::S3Storage.new }
  let(:object) { double }
  let(:bucket_name) { 'test-bucket' }
  let(:file_path) { File.dirname(__FILE__) }
  let(:key) { SecureRandom.uuid }
  let(:uri) { "urn:openhbx:terms:v1:file_storage:s3:bucket:<#{bucket_name}>##{key}" }
  let(:invalid_url) { "urn:openhbx:terms:v1:file_storage:s3:bucket:" }
  let(:file_content) { "test content" }

  describe "save()" do
    context "successful upload with explicit key" do
      it 'return the URI of saved file' do
        allow(object).to receive(:upload_file).with(file_path).and_return(true)
        allow_any_instance_of(Aws::S3Storage).to receive(:get_object).and_return(object)
        expect(subject.save(file_path, bucket_name, key)).to eq(uri)
      end
    end


    context "successful upload without explicit key" do
      it 'return the URI of saved file' do
        allow(object).to receive(:upload_file).with(file_path).and_return(true)
        allow_any_instance_of(Aws::S3Storage).to receive(:get_object).and_return(object)
        expect(subject.save(file_path, bucket_name)).to include("urn:openhbx:terms:v1:file_storage:s3:bucket:")
      end
    end

    context "failed upload" do
      it 'returns nil' do
        allow(object).to receive(:upload_file).with(file_path).and_return(nil)
        allow_any_instance_of(Aws::S3Storage).to receive(:get_object).and_return(object)
        expect(subject.save(file_path, bucket_name)).to be_nil
      end
    end
  end

  describe "find()" do
    context "success" do
      it "returns the file contents" do
        allow_any_instance_of(Aws::S3Storage).to receive(:get_object).and_return(object)
        allow_any_instance_of(Aws::S3Storage).to receive(:read_object).with(object).and_return(file_content)
        expect(subject.find(uri)).to eq(file_content)
      end
    end

    context "failure (invalid uri)" do
      it "returns nil" do
        allow_any_instance_of(Aws::S3Storage).to receive(:get_object).and_raise(Exception)
        expect(subject.find(invalid_url)).to be_nil
      end
    end
  end
end