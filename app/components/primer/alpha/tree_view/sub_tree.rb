# frozen_string_literal: true

module Primer
  module Alpha
    class TreeView
      class SubTree < Primer::Component
        renders_many :nodes, types: {
          leaf: {
            renders: lambda { |component_klass: LeafNode, label:, **system_arguments|
              component_klass.new(
                **system_arguments,
                level: level + 1,
                path: [*path, label],
                label: label
              )
            },

            as: :leaf
          },

          sub_tree: {
            renders: lambda { |component_klass: SubTreeNode, label:, **system_arguments|
              component_klass.new(
                **system_arguments,
                level: level + 1,
                path: [*path, label],
                label: label
              )
            },

            as: :sub_tree
          }
        }

        renders_one :loader, types: {
          spinner: {
            renders: lambda { |**system_arguments|
              SpinnerLoader.new(**system_arguments, level: level, path: path)
            },

            as: :loading_spinner
          },

          skeleton: {
            renders: lambda { |**system_arguments|
              SkeletonLoader.new(**system_arguments, level: level, path: path)
            },

            as: :loading_skeleton
          }
        }

        renders_one :no_items_message

        delegate :level, :path, :expanded?, to: :@container

        def initialize(**system_arguments)
          system_arguments[:data] = merge_data(
            system_arguments,
            { data: { target: "tree-view-sub-tree-node.subTree" } }
          )

          @container = SubTreeContainer.new(**system_arguments)
        end

        private

        def defer?
          loader?
        end
      end
    end
  end
end
