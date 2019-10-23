tiny = require "tiny"

IDTracker = tiny.system {
  filter: tiny.requireAll "id"
  onAdd: (entity) =>
    @[entity.id] = entity
  onRemove: (entity) =>
    @[entity.id] = nil
}

Time = tiny.processingSystem {
  filter: tiny.requireAll "time"
  process: (entity, dt) =>
    entity.time += dt
}

import graphics from love
import cos, sin from math
w, h = graphics.getDimensions!
MapDisplay = tiny.sortedSystem {
  compare: (a, b) =>
    if a.orbit and b.orbit
      a.orbit.hierarchy <= b.orbit.hierarchy
    else
      true
  filter: tiny.requireAny "orbit", tiny.requireAll("x", "y")
  draw: (t) =>
    graphics.translate w / 2, h / 2
    for entity in *@entities
      if orbit = entity.orbit
        orbit = entity.orbit
        -- orbital period
        --  real: T = 2pi * sqrt(a^3 / G*M)
        --  sim:  T = 2pi * speed_parameter
        entity.x = orbit.radius * cos(t / orbit.speed_parameter) + orbit.offset
        entity.y = orbit.radius * sin(t / orbit.speed_parameter) + orbit.offset
        if orbit.parent_id
          parent = IDTracker[orbit.parent_id]
          entity.x += parent.x
          entity.y += parent.y
      graphics.circle "fill", entity.x, entity.y, 5 -- TEMP radius
}

-- TEMP demo
sun = {
  id: 0
  x: 0,
  y: 0
}
planet = {
  id: 1
  orbit: {
    hierarchy: 1
    radius: 20
    parent_id: 0
    offset: love.math.random!
    speed_parameter: 0.5
  }
}
game = { time: 0 }
world = tiny.world MapDisplay, IDTracker, planet, sun, Time, game

love.update = (dt) ->
  world\update dt

love.draw = ->
  MapDisplay\draw game.time

love.keypressed = (key) ->
  if key == "escape" love.event.quit!
