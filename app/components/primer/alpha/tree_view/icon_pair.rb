# frozen_string_literal: true

module Primer
  module Alpha
    class TreeView
      class IconPair < Primer::Component
        renders_one :expanded_icon, lambda { |**system_arguments|
          Icon.new(**system_arguments)
        }

        renders_one :collapsed_icon, lambda { |**system_arguments|
          Icon.new(**system_arguments)
        }

        attr_reader :expanded
        alias expanded? expanded

        def initialize(expanded: false, **system_arguments)
          @expanded = expanded
          @system_arguments = deny_tag_argument(**system_arguments)
          @system_arguments[:tag] = :"tree-view-icon-pair"
        end
      end
    end
  end
end
