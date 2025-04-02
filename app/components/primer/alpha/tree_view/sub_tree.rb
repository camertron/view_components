# frozen_string_literal: true

module Primer
  module Alpha
    class TreeView
      class SubTree < Primer::Component
        attr_reader :expanded, :level
        alias expanded? expanded

        renders_many :items, types: {
          item: {
            renders: lambda { |component_klass: LeafItem, **system_arguments|
              component_klass.new(**system_arguments, level: level + 1)
            },

            as: :item
          },

          sub_tree: {
            renders: lambda { |component_klass: SubTreeItem, **system_arguments|
              component_klass.new(**system_arguments, level: level + 1)
            },

            as: :sub_tree
          }
        }

        def initialize(level:, expanded: false, **system_arguments)
          @system_arguments = deny_tag_argument(**system_arguments)
          @level = level
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
