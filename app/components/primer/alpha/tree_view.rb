# frozen_string_literal: true

module Primer
  module Alpha
    # TreeView is a hierarchical list of items that may have a parent-child relationship where children
    # can be toggled into view by expanding or collapsing their parent item.
    class TreeView < Primer::Component
      renders_many :items, types: {
        item: {
          renders: lambda { |component_klass: LeafItem, label:, **system_arguments|
            component_klass.new(
              **system_arguments,
              level: 1,
              path: [label],
              label: label
            )
          },

          as: :item
        },

        sub_tree: {
          renders: lambda { |component_klass: SubTreeItem, label:, **system_arguments|
            component_klass.new(
              **system_arguments,
              level: 1,
              path: [label],
              label: label
            )
          },

          as: :sub_tree
        }
      }

      def initialize(**system_arguments)
        @system_arguments = deny_tag_argument(**system_arguments)

        @system_arguments[:tag] = :ul
        @system_arguments[:role] = "tree"
        @system_arguments[:classes] = class_names(
          @system_arguments.delete(:classes),
          "TreeViewRootUlStyles"
        )
      end
    end
  end
end
