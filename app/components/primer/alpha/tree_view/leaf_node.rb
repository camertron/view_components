# frozen_string_literal: true

module Primer
  module Alpha
    class TreeView
      class LeafNode < Primer::Component
        renders_one :leading_visual, types: {
          icon: lambda { |label: nil, **system_arguments|
            Visual.new(
              visual: Icon.new(**system_arguments),
              label: label
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
          icon: lambda { |label: nil, **system_arguments|
            Visual.new(
              visual: Icon.new(**system_arguments),
              label: label
            )
          }
        }

        delegate :current?, :merge_system_arguments!, to: :@node

        def initialize(label:, **system_arguments)
          @label = label
          @system_arguments = system_arguments
          @system_arguments[:data] = merge_data(
            @system_arguments,
            data: { "node-type": "leaf" }
          )

          @node = Primer::Alpha::TreeView::Node.new(**@system_arguments)
        end

        def supports_children?
          false
        end
      end
    end
  end
end
