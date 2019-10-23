import graphics from love
import cos, sin, pi from math
export t = 0
tau = 2 * math.pi
w, h = graphics.getDimensions!

tiny = require "tiny"

MapDisplay = tiny.sortedSystem {
  compare: (a, b) =>
    a.orbit.hierarchy < b.orbit.hierarchy
  filter: tiny.requireAll "orbit"
  draw: =>
    graphics.translate w / 2, h / 2
    for e in *@entities
      entity = e.orbit
      -- orbital period
      --  real: T = 2pi * sqrt(a^3 / G*M)
      --  sim:  T = 2pi * speed_parameter
      entity.x = entity.radius * cos(t / entity.speed_parameter) + entity.offset
      entity.y = entity.radius * sin(t / entity.speed_parameter) + entity.offset
      if entity.parent
        entity.x += entity.parent.x
        entity.y += entity.parent.y
      graphics.circle "fill", entity.x, entity.y, 5
}

world = tiny.world MapDisplay

-- TEMP demo
sun = {
  x: 0,
  y: 0,
  orbit: { hierarchy: 0, radius: 0, offset: 0, speed_parameter: 1 }
}

planet = {
  orbit: {
    hierarchy: 1
    radius: 20
    parent: sun
    offset: love.math.random!
    speed_parameter: 0.5
  }
}

world\add planet, sun

love.update = (dt) ->
  t += dt
  world\update dt

love.draw = ->
  MapDisplay\draw!

love.keypressed = (key) ->
  if key == "escape" love.event.quit!
