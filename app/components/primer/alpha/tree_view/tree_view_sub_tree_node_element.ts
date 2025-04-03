import {controller, target} from '@github/catalyst'
import {TreeViewIconPairElement} from './tree_view_icon_pair_element'
import {observeMutationsUntilConditionMet} from '../../utils'
import {TreeViewIncludeFragmentElement} from './tree_view_include_fragment_element'

@controller
export class TreeViewSubTreeNodeElement extends HTMLElement {
  @target node: HTMLElement
  @target subTree: HTMLElement
  @target iconPair: TreeViewIconPairElement
  @target toggleButton: HTMLElement
  @target expandedToggleIcon: HTMLElement
  @target collapsedToggleIcon: HTMLElement
  @target includeFragment: TreeViewIncludeFragmentElement
  @target loadingIndicator: HTMLElement
  @target loadingFailureMessage: HTMLElement
  @target retryButton: HTMLButtonElement

  expanded: boolean
  #abortController: AbortController

  connectedCallback() {
    this.expanded = this.node.getAttribute('aria-expanded') === 'true'

    observeMutationsUntilConditionMet(
      this,
      () => Boolean(this.node) && Boolean(this.subTree),
      () => {
        this.#update()
      },
    )

    const {signal} = (this.#abortController = new AbortController())
    this.addEventListener('click', this, {signal})

    observeMutationsUntilConditionMet(
      this,
      () => Boolean(this.includeFragment),
      () => {
        this.includeFragment.addEventListener('load', this, {signal})
        this.includeFragment.addEventListener('error', this, {signal})
      },
    )

    observeMutationsUntilConditionMet(
      this,
      () => Boolean(this.retryButton),
      () => {
        this.retryButton.addEventListener(
          'click',
          event => {
            this.#handleRetryButtonEvent(event)
          },
          {signal},
        )
      },
    )
  }

  disconnectedCallback() {
    this.#abortController.abort()
  }

  handleEvent(event: Event) {
    if (event.target === this.toggleButton) {
      this.#handleToggleEvent(event)
    } else if (event.target === this.includeFragment) {
      this.#handleIncludeFragmentEvent(event)
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

  #handleIncludeFragmentEvent(event: Event) {
    switch (event.type) {
      // the request completed successfully
      case 'load':
        break

      // the request failed
      case 'error':
        this.loadingIndicator.hidden = true
        this.loadingFailureMessage.hidden = false
        break
    }
  }

  #handleRetryButtonEvent(event: Event) {
    if (event.type === 'click') {
      this.loadingFailureMessage.hidden = true
      this.loadingIndicator.hidden = false
      this.includeFragment.refetch()
    }
  }

  #update() {
    if (this.expanded) {
      this.subTree.hidden = false
      this.node.setAttribute('aria-expanded', 'true')

      if (this.iconPair) {
        this.iconPair.showExpanded()
      }

      if (this.expandedToggleIcon && this.collapsedToggleIcon) {
        this.expandedToggleIcon.removeAttribute('hidden')
        this.collapsedToggleIcon.setAttribute('hidden', 'hidden')
      }
    } else {
      this.subTree.hidden = true
      this.node.setAttribute('aria-expanded', 'false')

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

if (!window.customElements.get('tree-view-sub-tree-node')) {
  window.TreeViewSubTreeNodeElement = TreeViewSubTreeNodeElement
  window.customElements.define('tree-view-sub-tree-node', TreeViewSubTreeNodeElement)
}

declare global {
  interface Window {
    TreeViewSubTreeNodeElement: typeof TreeViewSubTreeNodeElement
  }
}
