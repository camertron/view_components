# frozen_string_literal: true

module Primer
  module Alpha
    class TreeView
      class SpinnerLoader < Primer::Component
        def initialize(src:, **system_arguments)
          @src = src
          @container = SubTreeContainer.new(**system_arguments, expanded: true)
        end
      end
    end
  end
end
