# frozen_string_literal: true

module Primer
  module Alpha
    class TreeView
      class SubTree < Primer::Component
        renders_many :items, types: {
          item: {
            renders: lambda { |component_klass: LeafItem, label:, **system_arguments|
              component_klass.new(
                **system_arguments,
                level: level + 1,
                path: [*path, label],
                label: label
              )
            },

            as: :item
          },

          sub_tree: {
            renders: lambda { |component_klass: SubTreeItem, label:, **system_arguments|
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

        delegate :level, :path, :expanded?, to: :@container

        def initialize(**system_arguments)
          system_arguments[:data] = merge_data(
            system_arguments,
            { data: { target: "tree-view-sub-tree-item.subTree" } }
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
