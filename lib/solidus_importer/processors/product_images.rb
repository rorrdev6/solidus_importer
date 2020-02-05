# frozen_string_literal: true

module SolidusImporter
  module Processors
    class ProductImages < Base
      def call(context)
        @data = context.fetch(:data)
        @product = context.fetch(:product) if product_image?
        context.merge!(check_data || save_images)
      end

      private

      def check_data
        if !product_image?
          {}
        elsif @product.blank?
          { success: false, messages: 'Missing required target product' }
        end
      end

      def prepare_image
        attachment = URI.open(@data['Image Src'])
        Spree::Image.new(attachment: attachment, alt: @data['Alt Text'])
      rescue StandardError => e
        @messages = e.message
        nil
      end

      def product_image?
        @product_image ||= @data['Image Src'].present?
      end

      def save_images
        image = prepare_image
        if image
          @product.images << image
          { success: true }
        else
          { success: false, messages: @messages || @product.errors.full_messages.join(', ') }
        end
      end
    end
  end
end
