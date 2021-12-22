tiny = require "tiny"

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

system = ->
  sun = makeEntity {
    x: 0, y: 0
    radius: 5
  }
  planet = makeEntity {
    radius: 1
    orbit: {
      hierarchy: 1
      radius: 20
      parent_id: sun.id
      offset: love.math.random!
      speed_parameter: 0.5
    }
  }
  world\add sun, planet

system!

love.update = (dt) ->
  world\update dt

love.draw = ->
  systems.MapDisplay\draw game.time

love.keypressed = (key) ->
  if key == "escape" love.event.quit!
