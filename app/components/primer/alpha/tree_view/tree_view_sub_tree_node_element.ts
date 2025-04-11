import {controller, target} from '@github/catalyst'
import {TreeViewIconPairElement} from './tree_view_icon_pair_element'
import {observeMutationsUntilConditionMet} from '../../utils'
import {TreeViewIncludeFragmentElement} from './tree_view_include_fragment_element'
import {TreeViewElement} from './tree_view'

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
  #activeElementIsLoader: boolean = false

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
    this.addEventListener('keydown', this, {signal})

    observeMutationsUntilConditionMet(
      this,
      () => Boolean(this.includeFragment),
      () => {
        this.includeFragment.addEventListener('loadstart', this, {signal})
        this.includeFragment.addEventListener('error', this, {signal})
        this.includeFragment.addEventListener('include-fragment-replace', this, {signal})
        this.includeFragment.addEventListener(
          'include-fragment-replaced',
          (e: Event) => {
            this.#handleIncludeFragmentEvent(e)
          },
          {signal},
        )
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
    } else if (event instanceof KeyboardEvent) {
      this.#handleKeyboardEvent(event)
    }
  }

  expand() {
    const alreadyExpanded = this.expanded

    this.expanded = true
    this.#update()

    if (!alreadyExpanded && this.treeView) {
      const path = this.treeView.getNodePath(this.node) || []

      this.treeView.dispatchEvent(
        new CustomEvent('treeViewNodeExpanded', {
          bubbles: true,
          detail: {
            node: this,
            type: 'sub-tree',
            path,
          },
        }),
      )
    }
  }

  collapse() {
    const alreadyCollapsed = !this.expanded

    this.expanded = false
    this.#update()

    if (!alreadyCollapsed && this.treeView) {
      // Prevent issue where currently focusable node is stuck inside a collapsed
      // sub-tree and no node in the entire tree can be focused
      const previousNode = this.subTree.querySelector("[tabindex='0']")
      previousNode?.setAttribute('tabindex', '-1')
      this.node.setAttribute('tabindex', '0')

      const path = this.treeView.getNodePath(this.node) || []

      this.treeView.dispatchEvent(
        new CustomEvent('treeViewNodeCollapsed', {
          bubbles: true,
          detail: {
            node: this,
            type: 'sub-tree',
            path,
          },
        }),
      )
    }
  }

  toggle() {
    if (this.expanded) {
      this.collapse()
    } else {
      this.expand()
    }
  }

  get nodes(): NodeListOf<Element> {
    return this.querySelectorAll(':scope > [role=treeitem]')
  }

  get isEmpty(): boolean {
    return this.nodes.length === 0
  }

  get treeView(): TreeViewElement | null {
    return this.closest('tree-view')
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

      // request succeeded but element has not yet been replaced
      case 'include-fragment-replace':
        this.loadingState = 'success'
        this.#activeElementIsLoader = document.activeElement === this.loadingIndicator.closest('li')
        this.#update()
        break

      case 'include-fragment-replaced':
        if (this.#activeElementIsLoader) {
          const firstItem = this.querySelector('[role=treeitem] [role=group] > :first-child') as HTMLElement | null
          if (!firstItem) return

          if (firstItem.tagName.toLowerCase() === 'tree-view-sub-tree-node') {
            const firstChild = firstItem.querySelector('[role=treeitem]') as HTMLElement | null
            firstChild?.focus()
          } else {
            firstItem?.focus()
          }
        }

        this.#activeElementIsLoader = false
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

  #handleKeyboardEvent(event: KeyboardEvent) {
    const node = (event.target as HTMLElement).closest('[role=treeitem]')
    if (!node || node.getAttribute('data-node-type') !== 'sub-tree') {
      return
    }

    switch (event.key) {
      case 'Enter':
        // eslint-disable-next-line no-restricted-syntax
        event.stopPropagation()
        this.toggle()
        break

      case 'ArrowRight':
        // eslint-disable-next-line no-restricted-syntax
        event.stopPropagation()
        this.expand()
        break

      case 'ArrowLeft':
        // eslint-disable-next-line no-restricted-syntax
        event.stopPropagation()
        this.collapse()
        break
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
