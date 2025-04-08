# frozen_string_literal: true

module Primer
  module Alpha
    class TreeView
      class LeadingAction < Primer::Component
        def initialize(action:)
          @action = action
        end
      end
    end
  end
end
