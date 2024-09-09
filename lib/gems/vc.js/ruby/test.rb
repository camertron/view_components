require "vcjs"
require "json"

definition = Dir.chdir("../js") do
  `npx tsx src/test.ts`
end

component_def = Vcjs::ComponentBuilder.build(JSON.parse(definition))
puts component_def.inspect
