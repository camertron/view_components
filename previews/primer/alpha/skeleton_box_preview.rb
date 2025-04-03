# frozen_string_literal: true

module Primer
  module Alpha
    # @label SkeletonBox
    class SkeletonBoxPreview < ViewComponent::Preview
      # @label Default
      def default
        render(Primer::Alpha::SkeletonBox.new(height: "64px", width: "64px"))
      end
    end
  end
end
