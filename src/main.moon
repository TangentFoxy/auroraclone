tiny = require "tiny"
MapDisplay = require "generators/MapDisplay"

systems = {}
for name in *love.filesystem.getDirectoryItems "systems"
  if ".lua" == name\sub -4
    name = name\sub 1, -5
    systems[#systems + 1] = require "systems/#{name}"
    systems[name] = systems[#systems]

game = {
  time: 0
  next_id: 0
}
makeEntity = (tab) ->
  tab.id = game.next_id
  game.next_id += 1
  return tab

world = tiny.world game, unpack systems
local map

system = ->
  system_id = "someuuidthing"
  sun = makeEntity {
    x: 0,
    y: 0
    [system_id]: true
  }
  planet = makeEntity {
    orbit: {
      hierarchy: 1
      radius: 20
      parent_id: sun.id
      offset: love.math.random!
      speed_parameter: 0.5
    }
    [system_id]: true
  }
  map = MapDisplay system_id
  world\add sun, planet
  world\add map

system!

love.update = (dt) ->
  world\update dt

love.draw = ->
  map\draw game.time

love.keypressed = (key) ->
  if key == "escape" love.event.quit!
