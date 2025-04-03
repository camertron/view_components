# frozen_string_literal: true

module Primer
  module Alpha
    class TreeView
      class SubTreeContainer < Primer::Component
        attr_reader :level, :path, :expanded

        alias expanded? expanded

        def initialize(level:, path:, expanded: false, **system_arguments)
          @system_arguments = deny_tag_argument(**system_arguments)
          @level = level
          @path = path
          @expanded = expanded

          @system_arguments[:tag] = :ul
          @system_arguments[:role] = :group
          @system_arguments[:p] = 0
          @system_arguments[:m] = 0
          @system_arguments[:style] = "list-style: none;"
          @system_arguments[:hidden] = !expanded?

          # @TODO: aria-label
        end
      end
    end
  end
end
