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

        attr_reader :checked

        DEFAULT_SELECT_VARIANT = :none
        SELECT_VARIANT_OPTIONS = [
          :multiple,
          DEFAULT_SELECT_VARIANT
        ].freeze

        DEFAULT_CHECKED_STATE = false
        CHECKED_STATES = [
          DEFAULT_CHECKED_STATE,
          true,
          'mixed'
        ]

        # @param path [Array<String>] The node's "path," i.e. this node's label and the labels of all its ancestors. This node should be reachable by traversing the tree following this path.
        # @param current [Boolean] Whether or not this node is the current node. The current node is styled differently than regular nodes and is the first element that receives focus when tabbing to the `TreeView` component.
        # @param select_variant [Symbol] Controls the type of checkbox that appears. <%= one_of(SELECT_VARIANT_OPTIONS) %>
        # @param checked [Boolean | String] The checked state of the node's checkbox. <%= one_of(CHECKED_STATES) %>
        # @param system_arguments [Hash] The arguments accepted by <%= link_to_component(Primer::Alpha::ActionList) %>.
        def initialize(
          path:,
          current: false,
          select_variant: DEFAULT_SELECT_VARIANT,
          checked: DEFAULT_CHECKED_STATE,
          **system_arguments
        )
          @system_arguments = deny_tag_argument(**system_arguments)

          @path = path
          @current = current
          @select_variant = fetch_or_fallback(SELECT_VARIANT_OPTIONS, select_variant, DEFAULT_SELECT_VARIANT)
          @checked = fetch_or_fallback(CHECKED_STATES, checked, DEFAULT_CHECKED_STATE)

          @system_arguments[:tag] = :li
          @system_arguments[:role] = :treeitem
          @system_arguments[:tabindex] = current? ? 0 : -1
          @system_arguments[:classes] = class_names(
            @system_arguments.delete(:classes),
            "TreeViewItem"
          )

          @system_arguments[:aria] = merge_aria(
            @system_arguments, {
              aria: {
                level: level,
                selected: false,
                checked: checked,
                labelledby: content_id
              }
            }
          )

          @system_arguments[:data] = merge_data(
            @system_arguments,
            { data: { path: @path.to_json } }
          )

          return unless current?

          @system_arguments[:aria] = merge_aria(
            @system_arguments,
            { aria: { current: true } }
          )
        end

        def level
          @level ||= @path.size
        end

        def merge_system_arguments!(**other_arguments)
          @system_arguments[:aria] = merge_aria(
            @system_arguments,
            other_arguments
          )

          @system_arguments[:data] = merge_data(
            @system_arguments,
            other_arguments
          )

          @system_arguments.merge!(**other_arguments)
        end

        private

        def before_render
          if leading_visual?
          end

          if leading_action?
            @system_arguments[:data] = merge_data(
              @system_arguments,
              { data: { "has-leading-action": true } }
            )
          end
        end

        def content_id
          @content_id ||= "#{base_id}-content"
        end

        def base_id
          @base_id ||= self.class.generate_id
        end
      end
    end
  end
end
