import {controller, target} from '@github/catalyst'
import {TreeViewIconPairElement} from './tree_view_icon_pair_element'
import {observeMutationsUntilConditionMet} from '../../utils'

@controller
export class TreeViewSubTreeItemElement extends HTMLElement {
  @target item: HTMLElement
  @target subTree: HTMLElement
  @target iconPair: TreeViewIconPairElement
  @target toggleButton: HTMLElement
  @target expandedToggleIcon: HTMLElement
  @target collapsedToggleIcon: HTMLElement

  expanded: boolean
  #abortController: AbortController

  connectedCallback() {
    this.expanded = this.item.getAttribute('aria-expanded') === 'true'

    observeMutationsUntilConditionMet(
      this,
      () => Boolean(this.item) && Boolean(this.subTree),
      () => {
        this.#update()
      },
    )

    const {signal} = (this.#abortController = new AbortController())
    this.addEventListener('click', this, {signal})
  }

  disconnectedCallback() {
    this.#abortController.abort()
  }

  handleEvent(event: Event) {
    if (event.target === this.toggleButton) {
      this.#handleToggleEvent(event)
    }
  }

  expand() {
    this.expanded = true
    this.#update()
  }

  collapse() {
    this.expanded = false
    this.#update()
  }

  #handleToggleEvent(event: Event) {
    if (event.type === 'click') {
      this.expanded = !this.expanded
      this.#update()
    }
  }

  #update() {
    if (this.expanded) {
      this.subTree.hidden = false
      this.item.setAttribute('aria-expanded', 'true')

      if (this.iconPair) {
        this.iconPair.showExpanded()
      }

      if (this.expandedToggleIcon && this.collapsedToggleIcon) {
        this.expandedToggleIcon.removeAttribute('hidden')
        this.collapsedToggleIcon.setAttribute('hidden', 'hidden')
      }
    } else {
      this.subTree.hidden = true
      this.item.setAttribute('aria-expanded', 'false')

      if (this.iconPair) {
        this.iconPair.showCollapsed()
      }

      if (this.expandedToggleIcon && this.collapsedToggleIcon) {
        this.expandedToggleIcon.setAttribute('hidden', 'hidden')
        this.collapsedToggleIcon.removeAttribute('hidden')
      }
    }
  }
}

if (!window.customElements.get('tree-view-sub-tree-item')) {
  window.TreeViewSubTreeItemElement = TreeViewSubTreeItemElement
  window.customElements.define('tree-view-sub-tree-item', TreeViewSubTreeItemElement)
}

declare global {
  interface Window {
    TreeViewSubTreeItemElement: typeof TreeViewSubTreeItemElement
  }
}
