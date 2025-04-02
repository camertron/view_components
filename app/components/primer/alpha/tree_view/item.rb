# frozen_string_literal: true

module Primer
  module Alpha
    class TreeView
      class Item < Primer::Component
        renders_one :leading_visual
        renders_one :trailing_visual

        renders_one :toggle

        def initialize(label:, level:, **system_arguments)
          @system_arguments = deny_tag_argument(**system_arguments)

          @system_arguments[:tag] = :li
          @system_arguments[:role] = :treeitem
          @system_arguments[:classes] = class_names(
            @system_arguments.delete(:classes),
            "TreeViewItem"
          )

          @label = label
          @level = level
        end
      end
    end
  end
end
