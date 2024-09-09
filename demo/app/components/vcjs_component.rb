# frozen_string_literal: true

class VcjsComponent < ViewComponent::Base
  def initialize(component_data)
    @component_def = Vcjs::ComponentBuilder.build(component_data)
  end

  private

  def component_klass
    @component_klass ||= Object.const_get(@component_def.klass)
  end

  def apply_slots(component_instance, slots, &block)
    slots.each do |slot_method, slot_defs|
      slot_defs.each do |slot_def|
        component_instance.send(slot_method, **slot_def.args) do |slot_instance|
          apply_slots(slot_instance, slot_def.slots, &block)
          slot_def.content
        end
      end
    end
  end
end
