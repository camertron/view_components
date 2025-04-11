# frozen_string_literal: true

require "components/test_helper"

module Primer
  module Alpha
    class TreeViewTest < Minitest::Test
      include Primer::ComponentTestHelpers

      def test_dom_structure
        render_preview(:default, params: { expanded: true })

        assert_selector("tree-view") do |tree|
          tree.assert_selector("ul[role=tree]") do |sub_tree|
            sub_tree.assert_selector("li[role=treeitem]") do |node|
              node.assert_selector(".TreeViewItemContainer", text: "src")
              node.assert_selector("ul[role=group]") do |sub_tree|
                sub_tree.assert_selector("li[role=treeitem]", text: "button.rb")
                sub_tree.assert_selector("li[role=treeitem]", text: "icon_button.rb")
              end
            end
          end
        end
      end

      def test_leading_visual_icon_pair_collapsed
        render_preview(:default)

        assert_selector("li[role=treeitem][data-path=\"[\\\"src\\\"]\"]") do |node|
          node.assert_selector(".TreeViewItemVisual tree-view-icon-pair") do |visual|
            visual.assert_selector("svg.octicon-file-directory-fill")
          end
        end
      end

      def test_leading_visual_icon_pair_expanded
        render_preview(:default, params: { expanded: true })

        assert_selector("li[role=treeitem][data-path=\"[\\\"src\\\"]\"]") do |node|
          node.assert_selector(".TreeViewItemVisual tree-view-icon-pair") do |visual|
            visual.assert_selector("svg.octicon-file-directory-open-fill")
          end
        end
      end
    end
  end
end
