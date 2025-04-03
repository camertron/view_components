# frozen_string_literal

module Primer
  module Alpha
    class TreeView
      class LoadingFailureMessage < Primer::Component
        DEFAULT_TEXT = "Something went wrong"
        DEFAULT_RETRY_BUTTON_LABEL = "Retry"

        def initialize(text: DEFAULT_TEXT, retry_button_label: DEFAULT_RETRY_BUTTON_LABEL, **system_arguments)
          @text = text
          @retry_button_label = retry_button_label
          @retry_button_arguments = system_arguments.delete(:retry_button_arguments)
          @system_arguments = deny_tag_argument(**system_arguments)
          @system_arguments[:tag] = :div
          @system_arguments[:classes] = class_names(
            @system_arguments.delete(:classes),
            "TreeViewFailureMessage"
          )
        end
      end
    end
  end
end
