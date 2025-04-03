# frozen_string_literal: true

module Primer
  module Alpha
    class TreeView
      class SkeletonLoader < Primer::Component
        renders_one :loading_failure_message, lambda { |**system_arguments|
          system_arguments[:retry_button_arguments] ||= {}
          system_arguments[:retry_button_arguments][:data] = merge_data(
            system_arguments[:retry_button_arguments],
            data: { target: "tree-view-sub-tree-node.retryButton" }
          )

          LoadingFailureMessage.new(**system_arguments)
        }

        def initialize(src:, count: 3, **system_arguments)
          @src = src
          @count = count

          @container = SubTreeContainer.new(**system_arguments, expanded: true)
        end
      end
    end
  end
end
