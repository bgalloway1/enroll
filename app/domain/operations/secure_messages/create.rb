# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

module Operations
  module SecureMessages
    class Create
      include Config::SiteConcern
      send(:include, Dry::Monads[:result, :do])

      #resource can be a profile or person who has inbox as embedded document

      def call(resource:, message_params:, document:)
        return Failure({:message => ['Please find valid resource to send the message']})  if resource.blank?

        payload = yield construct_message_payload(resource, message_params, document)
        validated_payload = yield validate_message_payload(payload)
        message_entity = yield create_message_entity(validated_payload)
        resource = yield create(resource, message_entity.to_h)

        Success(resource)
      end

      private

      def construct_message_payload(resource, message_params, document)
        body = if document.present?
                 message_params[:body] + "<br>You can download the notice by clicking this link " \
                   "<a href=" \
                   "#{Rails.application.routes.url_helpers.cartafact_document_download_path(resource.class.to_s,
                                                                                            resource.id.to_s, 'documents', document.id)}?content_type=#{document.format}&filename=#{document.title.gsub(/[^0-9a-z]/i,'')}.pdf&disposition=inline" \
                   " target='_blank'>" + document.title.gsub(/[^0-9a-z]/i,'') + "</a>"
               else
                 message_params[:body]
               end

        Success({ :subject => message_params[:subject],
                  :body => body,
                  :from => site_short_name })
      end

      def validate_message_payload(params)
        result = ::Validators::SecureMessages::MessageContract.new.call(params)
        result.success? ? Success(result.to_h) : Failure(result.errors.to_h)
      end

      def create_message_entity(params)
        message = ::Entities::SecureMessages::Message.new(params)
        Success(message)
      end

      def create(resource, message_entity)
        resource.inbox.messages << Message.new(message_entity)
        resource.save!
        Success(resource)
      end

    end
  end
end
