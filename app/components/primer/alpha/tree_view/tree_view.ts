import {controller} from '@github/catalyst'
import {TreeViewSubTreeNodeElement} from './tree_view_sub_tree_node_element'

@controller
export class TreeViewElement extends HTMLElement {
  #abortController: AbortController

  connectedCallback() {}

  disconnectedCallback() {
    this.#abortController.abort()
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

  nodeAtPath(path: string[], selector?: string): HTMLElement | null {
    const pathStr = JSON.stringify(path)
    return this.querySelector(`${selector}[data-path="${CSS.escape(pathStr)}"]`)
  }

  subTreeAtPath(path: string[]): TreeViewSubTreeNodeElement | null {
    const node = this.nodeAtPath(path, '[data-node-type=sub-tree]')
    if (!node) return null

    return node.closest('tree-view-sub-tree-node') as TreeViewSubTreeNodeElement | null
  }

  leafAtPath(path: string[]): HTMLLIElement | null {
    return this.nodeAtPath(path, '[data-node-type=leaf]') as HTMLLIElement | null
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
