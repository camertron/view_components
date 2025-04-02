# frozen_string_literal: true

module Primer
  module Alpha
    class FileTreeView
      class DirectoryItem < TreeView::SubTreeItem
        def with_file(**system_arguments, &block)
          with_item(**system_arguments, component_klass: FileItem, &block)
        end

        def with_directory(**system_arguments, &block)
          with_sub_tree(**system_arguments, component_klass: DirectoryItem, &block)
        end
      end
    end
  end
end
