body = {
  orbit: {
    parent: Body
    radius: #
    offset: #
    l4: {
      offset: #
      destination: ?
    }
    l5: {
      offset: #
    }
  }
  mass: #
  radius: #
  hydrosphere: {} -- pollutants, volume % (relative to planet surface)
  atmosphere: {}  -- volume, pressure, contents
  -- manufactoring, refining, etc -> introduces pollutants into hydrosphere and atmosphere
  populations: {
    {
      resources: {
        fuel: #
        reactives: #    -- jump drives, engines, research, life support
        radioactives: # -- fuel, heavy armor, kinetic weapons, sensors
        alloys: #       -- structure
        crystals: #     -- shields, stealth, ecm/eccm, energy weapons
        silicates: #    -- electronics, capacitors, energy weapons
        -- halogens: #
      }
      structures: {
        factory: {
          capacity: #
          pollution: {}
        }
        mine: {
          capacity: #
          pollution: {}
        }
        'fuel refinery': #
        -- 'type-strength OR type-value': #
        -- {type: 'name', value: #, cost: #, etc} ? -- actual list
      }
    }
  }
  minerals: ?
}

modules = {
  factory: {
    surface: true
    capacity: 10  -- research ++
    pollution: {} -- research --
    cost: {       -- research --
      alloys: 20
      silicates: 2
    }
  }
  mine: {
    surface: true
    capacity: 10  -- research ++
    pollution: {} -- research --
    cost: {       -- research ==
      alloys: 40
      silicates: 6
      reactives: 2
    }
  }
  'fuel refinery': {
    surface: true
    -- orbit: true -- research
    capacity: 100 -- research ++
    pollution: {} -- research --
    cost: {       -- research --
      alloys: 120
      reactives: 20
      crystals: 10
    }
  }
  'mass driver': {
    surface: true
    capacity: 2000 -- research ++
    pollution: {}  -- research --
    cost: {        -- research --
      alloys: 250
      reactives: 120
      radioactives: 20
      silicates: 10
    }
  }
  shipyard: {
    orbit: true
    capacity: 1000
    cost: {            -- research --
      alloys: 2200
      reactives: 180
      radioactives: 80
      silicates: 200
    }
  }

  -- research tech: shuttle range
    --   - salvage facility
    --   - orbital hab
    -- - hanger
    --   - maintenance facility
    -- - gas harvester
    -- - geo
    --   - terraforming
    --   - geo survey sensors
    --   - infrastructure
    -- - sensors
    --   - grav survey sensors
    --   - em sensors
    --   - thermal sensors
    --   - active sensors vs passive sensors
    --   - all sensors can provide tracking and targeting
    --   - bridge
    -- - research
    --   - chemical/physics/genetic/biology/xenology lab
    --   - university
    -- - ship
    --   - design considerations
    --     - deployment time adjusts how much mass is needed per crew
    --     - components designate required crew
    --     - armor area / structural hull requirements
    --     - speed, power use/requirement
    --     - build time, load time, mineral requirement
    --     - signature (th by engines, em by shielding/equipment)
    --     - maintenance life, estimated failure rate
    --     - damage allocation
    --     - em damage, shock damage
    --     - idea: based on volume, min distance before ships collide?
    --   - crew quarters
    --   - engineering section
    --   - main engineering
    --   - engines
    --   - jump drive
    --   - combat drop pods
    --   - tractor
    -- - cargo
    --   - fuel storage
    --   - supplies bay
    --   - shuttle bay (actually just hangers)
    --   - cargo hold
    --   - cryogenic transport
    -- - power plants
    -- - kinetic weapons
    --   - launcher
    --   - magazine
    -- - defense
    --   - armor
    --   - damage control
}
