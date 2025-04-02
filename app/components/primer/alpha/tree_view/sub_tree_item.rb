# frozen_string_literal: true

module Primer
  module Alpha
    class TreeView
      class SubTreeItem < Primer::Component
        renders_one :leading_visual, types: {
          icon: lambda { |**system_arguments|
            label = system_arguments.delete(:label)

            Visual.new(
              label: label,
              visual: Icon.new(**system_arguments)
            )
          },

          icons: lambda { |**system_arguments|
            label = system_arguments.delete(:label)

            system_arguments[:data] = merge_data(
              system_arguments,
              { data: { target: "tree-view-sub-tree-item.iconPair" } }
            )

            Visual.new(
              label: label,
              visual: IconPair.new(
                **system_arguments,
                expanded: @sub_tree.expanded?,
              )
            )
          }
        }

        renders_one :trailing_visual, types: {
          icon: lambda { |**system_arguments|
            label = system_arguments.delete(:label)

            Visual.new(
              visual: Icon.new(**system_arguments),
              label: label
            )
          }
        }

        delegate :with_item, :with_sub_tree, to: :@sub_tree

        def initialize(level:, expanded: false, **system_arguments)
          @system_arguments = system_arguments

          @system_arguments[:aria] = merge_aria(
            @system_arguments,
            { aria: { expanded: expanded } }
          )

          @system_arguments[:data] = merge_data(
            @system_arguments,
            { data: { target: "tree-view-sub-tree-item.item" } }
          )

          sub_tree_arguments = @system_arguments.delete(:sub_tree_arguments) || {}
          sub_tree_arguments[:data] = merge_data(
            sub_tree_arguments,
            { data: { target: "tree-view-sub-tree-item.subTree" } }
          )

          @sub_tree = SubTree.new(
            expanded: expanded,
            level: level,
            **sub_tree_arguments
          )
        end
      end
    end
  end
end
