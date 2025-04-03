# frozen_string_literal: true

module Primer
  module Alpha
    class TreeView
      class Item < Primer::Component
        renders_one :leading_visual
        renders_one :trailing_visual

        renders_one :toggle
        renders_one :text_content

        def initialize(level:, path:, current: false, **system_arguments)
          @system_arguments = deny_tag_argument(**system_arguments)

          @level = level
          @path = path

          @system_arguments[:tag] = :li
          @system_arguments[:role] = :treeitem
          @system_arguments[:classes] = class_names(
            @system_arguments.delete(:classes),
            "TreeViewItem"
          )

          @system_arguments[:aria] = merge_aria(
            @system_arguments,
            { aria: { current: current } }
          )

          @system_arguments[:data] = merge_data(
            @system_arguments,
            { data: { level: level, path: @path.to_json } }
          )
        end
      end
    end
  end
end
