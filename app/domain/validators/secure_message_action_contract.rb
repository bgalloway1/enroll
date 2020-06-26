# frozen_string_literal: true

module Validators
  class SecureMessageActionContract < ::Dry::Validation::Contract

    params do
      optional(:profile_id).maybe(:string)
      required(:actions_id).filled(:string)
      required(:subject).value(:string)
      required(:body).value(:string)
      optional(:file)
    end

    rule(:file) do
      key.failure('Invalid file format') if value.present? && !value.is_a?(ActionDispatch::Http::UploadedFile)
    end

    rule(:subject) do
      key.failure('Please enter subject') if value.blank?
    end

    rule(:body) do
      key.failure('Please enter content') if value.blank?
    end
  end
end
