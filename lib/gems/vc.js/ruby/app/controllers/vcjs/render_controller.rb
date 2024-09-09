# frozen_string_literal: true

require "json"

module Vcjs
  class RenderController < ApplicationController
    def show
      @component_data = JSON.parse(params[:payload])
    end
  end
end
