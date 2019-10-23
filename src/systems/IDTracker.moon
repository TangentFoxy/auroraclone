tiny = require "tiny"

IDTracker = tiny.system {
  filter: tiny.requireAll "id"
  onAdd: (entity) =>
    @[entity.id] = entity
  onRemove: (entity) =>
    @[entity.id] = nil
}

return IDTracker
