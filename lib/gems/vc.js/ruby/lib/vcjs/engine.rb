require "vcjs"

module Vcjs
  class Engine < ::Rails::Engine
    isolate_namespace Vcjs
  end
end
