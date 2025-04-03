# frozen_string_literal: true

module Primer
  module Alpha
    class TreeView
      class LeafNode < Primer::Component
        renders_one :leading_visual, types: {
          icon: lambda { |**system_arguments|
            label = system_arguments.delete(:label)

            Visual.new(
              visual: Icon.new(**system_arguments),
              label: label
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

        def initialize(label:, **system_arguments)
          @label = label
          @system_arguments = system_arguments
          @system_arguments[:data] = merge_data(
            @system_arguments,
            data: { "node-type": "leaf" }
          )
        end
      end
    end
  end
end
