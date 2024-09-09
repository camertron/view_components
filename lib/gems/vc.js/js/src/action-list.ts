import {type SerializedRubyObject, serializeString, serializeSysArgs, Sym, type SystemArguments} from './types'

export type SCHEME_OPTIONS = 'full' | 'inset'
export type SELECT_VARIANT_OPTIONS = 'none' | 'single' | 'multiple' | 'multiple_checkbox'
export type ARIA_SELECTION_VARIANT_OPTIONS = 'checked' | 'selected'

type ContentCallback<T> = T extends void ? () => string | undefined | void : (component: T) => string | undefined | void

class Slot<T> {
  public component: ViewComponent<T> | null
  public content: string | undefined

  constructor(component: ViewComponent<T> | null, content: string | undefined) {
    this.component = component
    this.content = content
  }

  serialize(): SerializedSlot {
    return {
      component: this.component?.serialize(),
      content: this.content ? serializeString(this.content) : undefined,
    }
  }
}

type SerializedSlot = {component?: SerializedComponent; content?: SerializedRubyObject}
type SerializedComponent = {
  ruby_class: string
  args: SerializedRubyObject
  slots: {[key: string]: SerializedSlot[]}
}

export abstract class ViewComponent<T = object> {
  protected args: T & SystemArguments
  protected singleSlots: Map<string, Slot<unknown>>
  protected manySlots: Map<string, Array<Slot<unknown>>>

  constructor(args: T & SystemArguments = {} as T & SystemArguments) {
    this.args = args
    this.singleSlots = new Map()
    this.manySlots = new Map()
  }

  with_content(content: string) {
    this.singleSlots.set('content', new Slot(null, content))
  }

  serialize(): SerializedComponent {
    const slots: Map<string, SerializedSlot[]> = new Map()
    this.serializeSingleSlotsInto(slots)
    this.serializeManySlotsInto(slots)

    return {
      ruby_class: this.rubyClass,
      args: serializeSysArgs(this.args),
      slots: Object.fromEntries(slots),
    }
  }

  abstract get rubyClass(): string

  private serializeSingleSlotsInto(map: Map<string, SerializedSlot[]>) {
    for (const [name, slot] of this.singleSlots) {
      map.set(name, [slot.serialize()])
    }
  }

  private serializeManySlotsInto(map: Map<string, SerializedSlot[]>) {
    for (const [name, slots] of this.manySlots) {
      const serializedMany: SerializedSlot[] = []

      for (const slot of slots) {
        serializedMany.push(slot.serialize())
      }

      map.set(name, serializedMany)
    }
  }
}

export type PrimerAlphaActionListArgs = {
  id?: string
  role?: string
  item_classes?: string
  scheme?: Sym<SCHEME_OPTIONS>
  show_dividers?: boolean
  select_variant?: Sym<SELECT_VARIANT_OPTIONS>
  aria_selection_variant?: Sym<ARIA_SELECTION_VARIANT_OPTIONS>
}

export class PrimerAlphaActionList extends ViewComponent<PrimerAlphaActionListArgs> {
  static rubyClass: string = 'Primer::Alpha::ActionList'

  static create(
    args: PrimerAlphaActionListArgs & SystemArguments = {},
    callback?: (component: PrimerAlphaActionList) => void,
  ): PrimerAlphaActionList {
    const instance = new PrimerAlphaActionList(args)
    if (callback) callback(instance)
    return instance
  }

  with_heading(
    {title, heading_level, subtitle, scheme, ...system_arguments}: PrimerAlphaActionListHeadingArgs & SystemArguments,
    callback?: ContentCallback<PrimerAlphaActionListHeading>,
  ) {
    const args = {title, heading_level, subtitle, scheme, ...system_arguments}
    const instance = new PrimerAlphaActionListHeading(args)
    const slot = new Slot(instance, (callback ? callback(instance) : undefined) || '')
    this.singleSlots.set('with_heading', slot)
  }

  with_item(
    {label, ...system_arguments}: PrimerAlphaActionListItemArgs & SystemArguments,
    callback?: ContentCallback<PrimerAlphaActionListItem>,
  ) {
    if (!this.manySlots.has('with_item')) {
      this.manySlots.set('with_item', [])
    }

    const args = {label, ...system_arguments}
    const instance = new PrimerAlphaActionListItem(args)

    this.manySlots.get('with_item')!.push(new Slot(instance, (callback ? callback(instance) : undefined) || ''))
  }

  get rubyClass(): string {
    return PrimerAlphaActionList.rubyClass
  }
}

type HEADER_SCHEME_OPTIONS = 'subtle' | 'filled'

export type PrimerAlphaActionListHeadingArgs = {
  title: string
  heading_level?: number
  subtitle?: string
  scheme?: Sym<HEADER_SCHEME_OPTIONS>
}

export class PrimerAlphaActionListHeading extends ViewComponent<PrimerAlphaActionListHeadingArgs> {
  static rubyClass = 'Primer::Alpha::ActionList::Heading'

  get rubyClass(): string {
    return PrimerAlphaActionListHeading.rubyClass
  }
}

export type PrimerAlphaActionListItemArgs = {
  label?: string
}

export type PrimerAlphaActionListDescriptionArgs = {
  legacy_content?: string
  test_selector?: string
}

export class PrimerAlphaActionListItem extends ViewComponent<PrimerAlphaActionListItemArgs> {
  static rubyClass = 'Primer::Alpha::ActionList::Item'

  with_description(args: PrimerAlphaActionListDescriptionArgs, callback: ContentCallback<void>) {
    this.singleSlots.set('description', new Slot(null, callback() || ''))
  }

  get rubyClass(): string {
    return PrimerAlphaActionListItem.rubyClass
  }
}
