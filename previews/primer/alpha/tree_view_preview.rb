# frozen_string_literal: true

module Primer
  module Alpha
    # @label TreeView
    class TreeViewPreview < ViewComponent::Preview
      def default
      end

      # @label Loading spinner
      #
      # @param simulate_failure toggle
      def loading_spinner(simulate_failure: false)
        render_with_template(locals: { simulate_failure: simulate_failure })
      end

      # @label Loading skeleton
      #
      # @param simulate_failure toggle
      def loading_skeleton(simulate_failure: false)
        render_with_template(locals: { simulate_failure: simulate_failure })
      end
    end
  end
end
