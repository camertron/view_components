import {controller, target} from '@github/catalyst'
import {TreeViewIconPairElement} from './tree_view_icon_pair_element'
import {observeMutationsUntilConditionMet} from '../../utils'
import {TreeViewIncludeFragmentElement} from './tree_view_include_fragment_element'

type LoadingState = 'loading' | 'error' | 'success'

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
  loadingState: LoadingState

  #abortController: AbortController

  connectedCallback() {
    this.expanded = this.node.getAttribute('aria-expanded') === 'true'
    this.loadingState = 'success'

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
        this.includeFragment.addEventListener('loadstart', this, {signal})
        this.includeFragment.addEventListener('error', this, {signal})
        this.includeFragment.addEventListener('load', (e: Event) => this.#handleIncludeFragmentEvent(e), {signal})
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

  toggle() {
    this.expanded = !this.expanded
    this.#update()
  }

  get nodes(): NodeListOf<Element> {
    return this.querySelectorAll(':scope > [role=treeitem]')
  }

  get isEmpty(): boolean {
    return this.nodes.length === 0
  }

  #handleToggleEvent(event: Event) {
    if (event.type === 'click') {
      this.toggle()
    }
  }

  #handleIncludeFragmentEvent(event: Event) {
    switch (event.type) {
      // the request has started
      case 'loadstart':
        this.loadingState = 'loading'
        this.#update()
        break

      // the request failed
      case 'error':
        this.loadingState = 'error'
        this.#update()
        break

      // request succeeded
      case 'load':
        this.loadingState = 'success'
        this.#update()
        break
    }
  }

  #handleRetryButtonEvent(event: Event) {
    if (event.type === 'click') {
      this.loadingState = 'loading'
      this.#update()

      this.includeFragment.refetch()
    }
  }

  #update() {
    if (this.expanded) {
      if (this.subTree) this.subTree.hidden = false
      this.node.setAttribute('aria-expanded', 'true')

      if (this.iconPair) {
        this.iconPair.showExpanded()
      }

      if (this.expandedToggleIcon && this.collapsedToggleIcon) {
        this.expandedToggleIcon.removeAttribute('hidden')
        this.collapsedToggleIcon.setAttribute('hidden', 'hidden')
      }
    } else {
      if (this.subTree) this.subTree.hidden = true
      this.node.setAttribute('aria-expanded', 'false')

      if (this.iconPair) {
        this.iconPair.showCollapsed()
      }

      if (this.expandedToggleIcon && this.collapsedToggleIcon) {
        this.expandedToggleIcon.setAttribute('hidden', 'hidden')
        this.collapsedToggleIcon.removeAttribute('hidden')
      }
    }

    switch (this.loadingState) {
      case 'loading':
        if (this.loadingFailureMessage) this.loadingFailureMessage.hidden = true
        if (this.loadingIndicator) this.loadingIndicator.hidden = false
        break

      case 'error':
        if (this.loadingIndicator) this.loadingIndicator.hidden = true
        if (this.loadingFailureMessage) this.loadingFailureMessage.hidden = false
        break

      // success/init case
      default:
        if (this.loadingIndicator) this.loadingIndicator.hidden = true
        if (this.loadingFailureMessage) this.loadingFailureMessage.hidden = true
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
