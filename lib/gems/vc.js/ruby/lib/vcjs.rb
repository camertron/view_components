# frozen_string_literal: true

module Vcjs
  autoload :Engine, "vcjs/engine"

  class ComponentDef
    attr_reader :klass, :args, :slots, :content

    def initialize(klass, args, slots, content)
      @klass = klass
      @args = args
      @slots = slots
      @content = content
    end
  end

  class SlotDef
    attr_reader :args, :slots, :content

    def initialize(args, slots, content)
      @args = args
      @slots = slots
      @content = content
    end
  end

  class ComponentBuilder
    class << self
      def build(definition)
        klass = definition["ruby_class"]
        args = deserialize(definition["args"]) || {}
        slots = build_slots(definition["slots"]) || {}
        ComponentDef.new(klass, args, slots, definition["content"])
      end

      private

      def build_slots(slot_map)
        return unless slot_map

        slot_map.each_with_object({}) do |(slot_name, slot_entries), memo|
          memo[slot_name] = slot_entries.map do |slot_entry|
            if slot_entry.include?("component")
              build_slot(slot_entry["component"])
            else
              SlotDef.new({}, {}, deserialize(slot_entry["content"]))
            end
          end
        end
      end

      def build_slot(slot_entry)
        args = deserialize(slot_entry["args"]) || {}
        slots = build_slots(slot_entry["slots"]) || {}
        SlotDef.new(args, slots, deserialize(slot_entry["content"]))
      end

      def deserialize(data)
        return unless data&.include?("value")

        case data["type"]
        when "hash"
          data["value"].each_with_object({}) do |hash_args, memo|
            key = deserialize(hash_args["key"])
            value = deserialize(hash_args["value"])
            memo[key] = value
          end
        when "array"
          data["value"].map { |v| deserialize(v) }
        when "string"
          data["value"].to_s
        when "symbol"
          data["value"].to_sym
        when "number"
          if data["value"].include?(".")
            data["value"].to_f
          else
            data["value"].to_i
          end
        when "boolean"
          data["value"]
        else
          raise "What the hell is a(n) #{data["type"]}"
        end
      end
    end
  end
end
