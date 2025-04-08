# frozen_string_literal: true

module Primer
  module Alpha
    class TreeView
      class Node < Primer::Component
        renders_one :leading_action
        renders_one :leading_visual
        renders_one :trailing_visual

        renders_one :toggle
        renders_one :text_content

        attr_reader :current
        alias current? current

        def initialize(path:, current: false, **system_arguments)
          @system_arguments = deny_tag_argument(**system_arguments)

          @path = path
          @current = current

          @system_arguments[:tag] = :li
          @system_arguments[:role] = :treeitem
          @system_arguments[:tabindex] = current? ? 0 : -1
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

        def level
          @level ||= @path.size
        end

        def merge_system_arguments!(**other_arguments)
          @system_arguments.merge!(**other_arguments)
        end

        private

        def before_render
          return unless leading_action?

          @system_arguments[:data] = merge_data(
            @system_arguments,
            { data: { "has-leading-action": true } }
          )
        end
      end
    end
  end
end
