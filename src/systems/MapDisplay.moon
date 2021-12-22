import graphics from love
import cos, sin from math

w, h = graphics.getDimensions!

tiny = require "tiny"
IDTracker = require "systems/IDTracker"

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
        --  sim:  T = 2pi / speed_parameter
        entity.x = orbit.radius * cos(t * orbit.speed_parameter) + orbit.offset
        entity.y = orbit.radius * sin(t * orbit.speed_parameter) + orbit.offset
        if orbit.parent_id
          parent = IDTracker[orbit.parent_id]
          entity.x += parent.x
          entity.y += parent.y
      graphics.circle "fill", entity.x, entity.y, entity.radius
}

return MapDisplay
