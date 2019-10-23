tiny = require "tiny"

Time = tiny.processingSystem {
  filter: tiny.requireAll "time"
  process: (entity, dt) =>
    entity.time += dt
}

return Time
