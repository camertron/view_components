# frozen_string_literal: true

require "json"

class VcjsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "vcjs"
  end

  def receive(data)
    component_data = data["payload"]
    request_id = data["request_id"]

    result = Vcjs::RenderController.renderer.render(
      :show, assigns: { component_data: component_data }, layout: false
    )

    ActionCable.server.broadcast(
      "vcjs",
      { payload: result, request_id: request_id }
    )
  end
end
