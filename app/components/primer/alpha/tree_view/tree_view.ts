import {controller} from '@github/catalyst'
import {TreeViewSubTreeNodeElement} from './tree_view_sub_tree_node_element'
import {useRovingTabIndex} from './tree_view_roving_tab_index'

@controller
export class TreeViewElement extends HTMLElement {
  #abortController: AbortController

  connectedCallback() {
    const {signal} = (this.#abortController = new AbortController())
    this.addEventListener('click', this, {signal})
    this.addEventListener('focusin', this, {signal})
    this.addEventListener('keydown', this, {signal})

    useRovingTabIndex(this)
  }

  disconnectedCallback() {
    this.#abortController.abort()
  }

  handleEvent(event: Event) {
    const node = this.#nodeForEvent(event)

    if (node) {
      this.#handleNodeEvent(node, event)
    }
  }

  #eventIsActivation(event: Event): boolean {
    return event.type === 'click'
  }

  #nodeForEvent(event: Event): Element | null {
    const target = event.target as Element
    const node = target.closest('[role=treeitem]')
    if (!node) return null

    if (target.closest('.TreeViewItemToggle')) return null
    if (target.closest('.TreeViewItemLeadingAction')) return null

    return node
  }

  #handleNodeEvent(node: Element, event: Event) {
    if (this.#eventIsCheckboxToggle(event)) {
      this.#handleCheckboxToggle(node)
    } else if (this.#eventIsActivation(event)) {
      this.#handleNodeActivated(node)
    } else if (event.type === 'focusin') {
      this.#handleNodeFocused(node)
    } else if (event instanceof KeyboardEvent) {
      this.#handleNodeKeyboardEvent(event, node)
    }
  }

  #eventIsCheckboxToggle(event: Event) {
    return event.type === 'click' && (event.target as HTMLElement).closest('.TreeViewItemCheckbox') !== null
  }

  #handleCheckboxToggle(node: Element) {
    // only handle checking of leaf nodes
    const type = this.getNodeType(node)
    if (type !== 'leaf') return

    if (this.#isNodeChecked(node)) {
      this.#setNodeChecked(node, 'false')
    } else {
      this.#setNodeChecked(node, 'true')
    }
  }

  #handleNodeActivated(node: Element) {
    const path = this.getNodePath(node)
    const type = this.getNodeType(node)

    const activationSuccess = this.dispatchEvent(
      new CustomEvent('treeViewBeforeNodeActivated', {
        bubbles: true,
        cancelable: true,
        detail: {
          node,
          type,
          path,
        },
      }),
    )

    if (!activationSuccess) return

    this.toggleAtPath(path)

    this.dispatchEvent(
      new CustomEvent('treeViewNodeActivated', {
        bubbles: true,
        detail: {
          node,
          type,
          path,
        },
      }),
    )
  }

  #handleNodeFocused(node: Element) {
    const previousNode = this.querySelector('[aria-selected=true]')
    previousNode?.setAttribute('aria-selected', 'false')
    node.setAttribute('aria-selected', 'true')
  }

  #handleNodeKeyboardEvent(event: KeyboardEvent, node: Element) {
    if (!node || this.getNodeType(node) !== 'leaf') {
      return
    }

    switch (event.key) {
      case ' ':
        event.preventDefault()

        if (this.#isNodeChecked(node)) {
          this.#setNodeChecked(node, 'false')
        } else {
          this.#setNodeChecked(node, 'true')
        }

        break
    }
  }

  getNodePath(node: Element): string[] {
    const rawPath = node.getAttribute('data-path')

    if (rawPath) {
      return JSON.parse(rawPath)
    }

    return []
  }

  getNodeType(node: Element): string | null {
    return node.getAttribute('data-node-type')
  }

  markCurrentAtPath(path: string[]) {
    const pathStr = JSON.stringify(path)
    const nodeToMark = this.querySelector(`[data-path="${CSS.escape(pathStr)}"`)
    if (!nodeToMark) return

    this.currentNode?.setAttribute('aria-current', 'false')
    nodeToMark.setAttribute('aria-current', 'true')
  }

  get currentNode(): HTMLLIElement | null {
    return this.querySelector('[aria-current=true]')
  }

  expandAtPath(path: string[]) {
    const node = this.subTreeAtPath(path)
    if (!node) return

    node.expand()
  }

  collapseAtPath(path: string[]) {
    const node = this.subTreeAtPath(path)
    if (!node) return

    node.collapse()
  }

  toggleAtPath(path: string[]) {
    const node = this.subTreeAtPath(path)
    if (!node) return

    node.toggle()
  }

  checkAtPath(path: string[]) {
    const node = this.nodeAtPath(path)
    if (!node) return

    this.#setNodeChecked(node, 'true')
  }

  uncheckAtPath(path: string[]) {
    const node = this.nodeAtPath(path)
    if (!node) return

    this.#setNodeChecked(node, 'false')
  }

  toggleCheckedAtPath(path: string[]) {
    if (this.isCheckedAtPath(path)) {
      this.uncheckAtPath(path)
    } else {
      this.checkAtPath(path)
    }
  }

  isCheckedAtPath(path: string[]): boolean {
    const node = this.nodeAtPath(path)
    if (!node) return false

    return this.#isNodeChecked(node)
  }

  nodeAtPath(path: string[], selector?: string): HTMLElement | null {
    const pathStr = JSON.stringify(path)
    return this.querySelector(`${selector || ''}[data-path="${CSS.escape(pathStr)}"]`)
  }

  subTreeAtPath(path: string[]): TreeViewSubTreeNodeElement | null {
    const node = this.nodeAtPath(path, '[data-node-type=sub-tree]')
    if (!node) return null

    return node.closest('tree-view-sub-tree-node') as TreeViewSubTreeNodeElement | null
  }

  leafAtPath(path: string[]): HTMLLIElement | null {
    return this.nodeAtPath(path, '[data-node-type=leaf]') as HTMLLIElement | null
  }

  #setNodeChecked(node: Element, value: 'true' | 'false' | 'mixed') {
    node.setAttribute('aria-checked', value)
  }

  #isNodeChecked(node: Element): boolean {
    const ariaChecked = node.getAttribute('aria-checked')
    return ariaChecked === 'true' || ariaChecked === 'mixed'
  }
}

if (!window.customElements.get('tree-view')) {
  window.TreeViewElement = TreeViewElement
  window.customElements.define('tree-view', TreeViewElement)
}

declare global {
  interface Window {
    TreeViewElement: typeof TreeViewElement
  }
}
