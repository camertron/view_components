# frozen_string_literal: true

module Primer
  module Alpha
    class TreeView
      class Visual < Primer::Component
        def initialize(visual:, label: nil)
          @visual = visual
          @label = label
        end

        def render_in(_view_context, &block)
          block&.call(@visual)
          super
        end
      end
    end
  end
end
