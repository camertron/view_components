# frozen_string_literal: true

require "json"

# :nodoc:
class TreeViewItemsController < ApplicationController
  TREE = JSON.parse(File.read(File.join(__dir__, "tree_view_items.json"))).freeze

  def index
    # delay a bit so loading spinners, etc can be seen
    sleep 1

    path = JSON.parse(params[:path])
    node = path.inject(TREE) do |current, segment|
      current["children"][segment]
    end

    entries = (
      node["children"].keys.map { |label| [label, :directory] } +
      node["files"].map { |label| [label, :file] }
    )

    entries.sort_by!(&:first)

    respond_to do |format|
      format.any(:html, :html_fragment) do
        render(
          "tree_view_items/index",
          locals: { entries: entries, path: path, loader: (params[:loader] || :spinner).to_sym },
          layout: false,
          formats: [:html, :html_fragment]
        )
      end
    end
  end
end
