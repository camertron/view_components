# frozen_string_literal: true

module Primer
  module Alpha
    # @label TreeView
    class TreeViewPreview < ViewComponent::Preview
      def default
      end

      def playground
      end

      # @label Loading spinner
      #
      # @param simulate_failure toggle
      # @param simulate_empty toggle
      def loading_spinner(simulate_failure: false, simulate_empty: false)
        render_with_template(locals: {
          simulate_failure: simulate_failure,
          simulate_empty: simulate_empty
        })
      end

      # @label Loading skeleton
      #
      # @param simulate_failure toggle
      # @param simulate_empty toggle
      def loading_skeleton(simulate_failure: false, simulate_empty: false)
        render_with_template(locals: {
          simulate_failure: simulate_failure,
          simulate_empty: simulate_empty
        })
      end
    end
  end
end
