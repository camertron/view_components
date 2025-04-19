# frozen_string_literal: true

module Primer
  module Alpha
    class TreeView
      class SubTreeNode < Primer::Component
        renders_one :leading_visual, types: {
          icon: lambda { |label: nil, **system_arguments|
            merge_system_arguments!(
              aria: { describedby: leading_visual_label_id }
            )

            Visual.new(
              id: leading_visual_label_id,
              label: label,
              visual: Icon.new(**system_arguments)
            )
          },

          icons: lambda { |label: nil, **system_arguments|
            merge_system_arguments!(
              aria: { describedby: leading_visual_label_id }
            )

            system_arguments[:data] = merge_data(
              system_arguments,
              { data: { target: "tree-view-sub-tree-node.iconPair" } }
            )

            Visual.new(
              id: leading_visual_label_id,
              label: label,
              visual: IconPair.new(
                **system_arguments,
                expanded: @sub_tree.expanded?,
              )
            )
          }
        }

        renders_one :leading_action, types: {
          button: lambda { |**system_arguments|
            LeadingAction.new(
              action: Primer::Beta::IconButton.new(
                scheme: :invisible,
                **system_arguments
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

        delegate :with_leaf, :with_sub_tree, :with_loading_spinner, :with_loading_skeleton, to: :@sub_tree
        delegate :current?, :merge_system_arguments!, to: :@node

        def initialize(label:, path:, expanded: false, **system_arguments)
          @label = label
          @system_arguments = system_arguments

          @system_arguments[:aria] = merge_aria(
            @system_arguments,
            { aria: { expanded: expanded } }
          )

          @system_arguments[:data] = merge_data(
            @system_arguments, {
              data: {
                target: "tree-view-sub-tree-node.node",
                "node-type": "sub-tree"
              }
            }
          )

          sub_tree_arguments = @system_arguments.delete(:sub_tree_arguments) || {}

          @sub_tree = SubTree.new(
            expanded: expanded,
            path: path,
            **sub_tree_arguments
          )

          @node = Primer::Alpha::TreeView::Node.new(**@system_arguments, path: @sub_tree.path)
        end

        private

        def base_id
          @base_id ||= self.class.generate_id
        end

        def leading_visual_label_id
          @leading_visual_id ||= "#{base_id}-leading-visual-label"
        end
      end
    end
  end
end
