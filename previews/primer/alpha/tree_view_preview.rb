# frozen_string_literal: true

module Primer
  module Alpha
    # @label TreeView
    class TreeViewPreview < ViewComponent::Preview
      # @param expanded [Boolean] toggle
      def default(expanded: false)
        render_with_template(locals: {
          expanded: coerce_bool(expanded)
        })
      end

      def playground
      end

      # @label Loading spinner
      #
      # @param simulate_failure [Boolean] toggle
      # @param simulate_empty [Boolean] toggle
      def loading_spinner(simulate_failure: false, simulate_empty: false)
        render_with_template(locals: {
          simulate_failure: simulate_failure,
          simulate_empty: simulate_empty
        })
      end

      # @label Loading skeleton
      #
      # @param simulate_failure [Boolean] toggle
      # @param simulate_empty [Boolean] toggle
      def loading_skeleton(simulate_failure: false, simulate_empty: false)
        render_with_template(locals: {
          simulate_failure: simulate_failure,
          simulate_empty: simulate_empty
        })
      end

      private

      def coerce_bool(value)
        case value
        when true, false
          value
        when "true"
          true
        when "false"
          false
        else
          false
        end
      end
    end
  end
end
