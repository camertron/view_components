export type ItemActivatedEvent = {
  item: Element
  checked: boolean
  value: string | null
}

export type TreeViewEvent = {
  node: Element
  type: 'leaf' | 'sub-tree'
  path: string[]
}

declare global {
  interface HTMLElementEventMap {
    itemActivated: CustomEvent<ItemActivatedEvent>
    beforeItemActivated: CustomEvent<ItemActivatedEvent>

    treeViewNodeActivated: CustomEvent<TreeViewEvent>
    treeViewBeforeNodeActivated: CustomEvent<TreeViewEvent>
    treeViewNodeExpanded: CustomEvent<TreeViewEvent>
    treeViewNodeCollapsed: CustomEvent<TreeViewEvent>
  }
}
