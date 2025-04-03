# frozen_string_literal: true

module Primer
  module Alpha
    class TreeView
      class SkeletonLoader < Primer::Component
        def initialize(src:, count: 3, **system_arguments)
          @src = src
          @count = count

          @container = SubTreeContainer.new(**system_arguments, expanded: true)
        end
      end
    end
  end
end
