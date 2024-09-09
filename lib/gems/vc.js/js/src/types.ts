export type SerializedRubyObject =
  | {
      type: 'array'
      value: SerializedRubyObject[] | undefined
    }
  | {
      type: 'hash'
      value: Array<{key: SerializedRubyObject; value: SerializedRubyObject | undefined}> | undefined
    }
  | {
      type: 'number'
      value: number | undefined
    }
  | {
      type: 'string'
      value: string | undefined
    }
  | {
      type: 'symbol'
      value: string | undefined
    }
  | {
      type: 'boolean'
      value: boolean | undefined
    }
  | {
      type: 'nil'
      value: null | undefined
    }

export class Sym<T extends string> {
  public value: T

  constructor(value: T) {
    this.value = value
  }

  serialize(): SerializedRubyObject {
    return {
      type: 'symbol',
      value: this.value,
    }
  }
}

export const serializeString = (str?: string): SerializedRubyObject => {
  return {type: 'string', value: str}
}

export const serializeNumber = (num?: number): SerializedRubyObject => {
  return {type: 'number', value: num}
}

export const serializeBoolean = (bool?: boolean): SerializedRubyObject => {
  return {type: 'boolean', value: bool}
}

export const serializeSysArgs = (args?: SystemArguments): SerializedRubyObject => {
  const results: Array<{key: {type: 'symbol'; value: string}; value: SerializedRubyObject | undefined}> = []

  if (args) {
    for (const k in args) {
      const v = args[k]
      if (v === undefined) continue

      const kSym: {type: 'symbol'; value: string} = {type: 'symbol', value: k}

      if (typeof v === 'string') {
        results.push({key: kSym, value: serializeString(v)})
      } else if (typeof v === 'number') {
        results.push({key: kSym, value: serializeNumber(v)})
      } else if (v === true || v === false) {
        results.push({key: kSym, value: serializeBoolean(v)})
      } else if (v instanceof Sym) {
        results.push({key: kSym, value: v.serialize()})
      } else if (v === null) {
        results.push({key: kSym, value: {type: 'nil', value: v}})
      }
    }
  }

  return {type: 'hash', value: results}
}

export type SystemArgument = string | number | boolean | Sym<string> | null | undefined
export type SystemArguments = {[key: string]: SystemArgument}
