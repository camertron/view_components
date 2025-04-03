# frozen_string_literal: true

module Primer
  module Alpha
    class SkeletonBox < Primer::Component
      def initialize(height: nil, width: nil, **system_arguments)
        @system_arguments = deny_tag_argument(**system_arguments)

        @system_arguments[:tag] = :div
        @system_arguments[:style] = "height: #{height}; width: #{width}"
        @system_arguments[:classes] = class_names(
          @system_arguments.delete(:classes),
          "SkeletonBox"
        )
      end
    end
  end
end
