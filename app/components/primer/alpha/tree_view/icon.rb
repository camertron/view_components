# frozen_string_literal: true

module Primer
  module Alpha
    class TreeView
      class Icon < Primer::Component
        def initialize(**system_arguments)
          @system_arguments = system_arguments
          @system_arguments[:focusable] = "false"
          @system_arguments[:display] = :inline_block
          @system_arguments[:overflow] = :visible
          @system_arguments[:style] = "vertical-align: text-bottom;"
        end
      end
    end
  end
end
