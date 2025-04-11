# frozen_string_literal: true

require "system/test_case"

module Alpha
  class IntegrationTreeViewTest < System::TestCase
    include Primer::KeyboardTestHelpers
    include Primer::JsTestHelpers

    ##### TEST HELPERS #####

    def selector_for(*path)
      path_selector = path.to_json.gsub('"', '\"')
      "[role=treeitem][data-path=\"#{path_selector}\"]"
    end

    def activate_at_path(*path)
      find(selector_for(*path), match: :first).trigger(:click)
    end

    def label_at_path(*path)
      label_of(node_at_path(*path))
    end

    def label_of(node)
      return unless node
      return unless node.tag_name == "li"
      return unless node["role"] == "treeitem"

      node.find_css(".TreeViewItemContentText").first.node.text
    end

    def node_at_path(*path)
      find(selector_for(*path), match: :first)
    end

    def current_node
      find_all("[role=treeitem][aria-current]").first
    end

    def active_element
      page.evaluate_script("document.activeElement")
    end

    def assert_path(*path)
      assert_selector selector_for(*path)
    end

    def refute_path(*path)
      refute_selector selector_for(*path)
    end

    def assert_path_tabbable(*path)
      assert_selector "#{selector_for(*path)}[tabindex='0']"
    end

    def assert_path_selected(*path)
      assert_selector "#{selector_for(*path)}[aria-selected=true]"
    end

    def remove_fail_param_from_fragment_src_for(*path)
      evaluate_multiline_script(<<~JS)
        const selector = CSS.escape(JSON.stringify(#{path.inspect}))
        const includeFragment = document.querySelector(`[data-path="${selector}"] tree-view-include-fragment`)
        const relativeUrl = includeFragment.getAttribute('src')
        const url = new URL(relativeUrl, 'http://dummy')
        url.searchParams.delete('fail')
        const newUrl = `${url.pathname}?${url.searchParams.toString()}`
        includeFragment.setAttribute('src', newUrl)
      JS
    end

    ##### TESTS #####

    def test_expands
      visit_preview(:default)
      activate_at_path("src")

      assert_path "src", "button.rb"
      assert_path "src", "icon_button.rb"

      node_at_path("src").tap do |node|
        assert_equal "true", node["aria-expanded"]
      end
    end

    def test_collapses
      visit_preview(:default)
      activate_at_path("src")

      node_at_path("src").tap do |node|
        assert_equal "true", node["aria-expanded"]
      end

      # should collapse
      activate_at_path("src")

      refute_path "src", "button.rb"
      refute_path "src", "icon_button.rb"

      node_at_path("src").tap do |node|
        assert_equal "false", node["aria-expanded"]
      end
    end

    def test_expanded_and_collapsed_icons
      visit_preview(:default)

      assert_selector "#{selector_for("src")} .TreeViewItemVisual svg.octicon-file-directory-fill"
      activate_at_path("src")
      assert_selector "#{selector_for("src")} .TreeViewItemVisual svg.octicon-file-directory-open-fill"
    end

    def test_current
      visit_preview(:default)

      refute current_node
      activate_at_path("src")

      assert current_node
      assert_equal label_of(current_node), "icon_button.rb"
    end

    def test_first_item_tabbable_when_no_current
      visit_preview(:default)

      assert_path_tabbable("src")
    end

    def test_current_item_tabbable
      visit_preview(:default, expanded: true)

      assert_path_tabbable("src", "icon_button.rb")
    end

    def test_tab_selects_current_item
      visit_preview(:default, expanded: true)

      refute label_of(active_element)

      keyboard.type(:tab)

      assert_equal label_of(active_element), "icon_button.rb"
      assert_path_selected("src", "icon_button.rb")
    end

    def test_arrow_down_selects_next_visible_node
      visit_preview(:default)

      keyboard.type(:tab, :down)

      assert_equal label_of(active_element), "action_menu.rb"
      assert_path_selected("action_menu.rb")
    end

    def test_arrow_down_selects_expanded_item
      visit_preview(:default)

      keyboard.type(:tab, :enter, :down)

      assert_equal label_of(active_element), "button.rb"
      assert_path_selected("src", "button.rb")
    end

    def test_tree_tabbable_after_parent_of_focused_item_is_collapsed
      visit_preview(:default, expanded: true)

      keyboard.type(:tab)
      assert_path_selected("src", "icon_button.rb")

      activate_at_path("src")

      # collapsed node now tabbable
      assert_path_tabbable("src")
    end

    ##### LOADERS #####

    def test_loading_spinner
      visit_preview(:loading_spinner)

      activate_at_path("primer")

      # assert loader appears and is subsequently replaced
      assert_selector "#{selector_for("primer", "loader")} svg"
      assert_selector "#{selector_for("primer", "alpha")}"

      # assert loader is gone
      refute_selector "#{selector_for("primer", "loader")}"
    end

    def test_selecting_spinner_causes_selection_to_move_to_first_loaded_node
      visit_preview(:loading_spinner)

      keyboard.type(:tab, :enter)
      assert_path("primer", "loader")
      keyboard.type(:down)

      assert_path_selected("primer", "alpha")
    end

    def test_loading_spinner_failure
      visit_preview(:loading_spinner, simulate_failure: true)

      activate_at_path("primer")

      assert_selector "#{selector_for("primer")} .TreeViewFailureMessage", text: "Something went wrong"
    end

    def test_loading_spinner_retry_after_failure
      visit_preview(:loading_spinner, simulate_failure: true)

      activate_at_path("primer")
      assert_selector "#{selector_for("primer")} .TreeViewFailureMessage"

      remove_fail_param_from_fragment_src_for("primer")
      click_on("Retry")

      assert_path("primer", "alpha")
      refute_selector "#{selector_for("primer")} .TreeViewFailureMessage"
    end

    def test_empty_after_loading_spinner
      visit_preview(:loading_spinner, simulate_empty: true)

      activate_at_path("primer")

      assert_selector "#{selector_for("primer")} .TreeViewItemContentText", text: "No items"
    end

    def test_loading_skeleton
      visit_preview(:loading_skeleton)

      activate_at_path("primer")

      # assert loader appears and is subsequently replaced
      assert_selector "#{selector_for("primer", "loader")} .SkeletonBox"
      assert_selector "#{selector_for("primer", "alpha")}"

      # assert loader is gone
      refute_selector "#{selector_for("primer", "loader")}"
    end

    def test_selecting_skeleton_causes_selection_to_move_to_first_loaded_node
      visit_preview(:loading_skeleton)

      keyboard.type(:tab, :enter)
      assert_path("primer", "loader")
      keyboard.type(:down)

      assert_path_selected("primer", "alpha")
    end

    def test_loading_skeleton_failure
      visit_preview(:loading_skeleton, simulate_failure: true)

      activate_at_path("primer")

      assert_selector "#{selector_for("primer")} .TreeViewFailureMessage", text: "Something went wrong"
    end

    def test_loading_skeleton_retry_after_failure
      visit_preview(:loading_skeleton, simulate_failure: true)

      activate_at_path("primer")
      assert_selector "#{selector_for("primer")} .TreeViewFailureMessage"

      remove_fail_param_from_fragment_src_for("primer")
      click_on("Retry")

      assert_path("primer", "alpha")
      refute_selector "#{selector_for("primer")} .TreeViewFailureMessage"
    end

    def test_empty_after_loading_skeleton
      visit_preview(:loading_skeleton, simulate_empty: true)

      activate_at_path("primer")

      assert_selector "#{selector_for("primer")} .TreeViewItemContentText", text: "No items"
    end

    def test_empty
      visit_preview(:empty)

      activate_at_path("src")

      assert_selector "#{selector_for("src")} .TreeViewItemContentText", text: "No items"
    end
  end
end
