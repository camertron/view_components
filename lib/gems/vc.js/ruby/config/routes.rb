# frozen_string_literal: true

Vcjs::Engine.routes.draw do
  get "/render", to: "render#show"
end
