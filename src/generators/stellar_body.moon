-- TODO defined globals need to be created somewhere else
export stefan_boltzmann_constant = 5.670374419e-8 -- W / (m^2 * K^4)

parameters = {
  temperature: love.math.randomNormal 1000, 6000 -- [2000 to 10000] K
}

parameters.absolute_magnitude = 35.4631241560502 * math.exp(-0.000353006569939 * parameters.temperature) -- Mv
parameters.luminosity = 100 * math.exp -0.943865141164545 * (parameters.absolute_magnitude - 0.99^parameters.absolute_magnitude) -- L(sun)
-- TODO calculate B-V value ? Or color directly? Or spectrum?

-- TODO this needs to be multiplied by the star's surface area to get its total power emission
parameters.surface_power_emission = stefan_boltzmann_constant * parameters.temperature^4 -- W / m^2
-- NOTE then for measuring power input into a planet, find the surface area of
-- its orbital radius, divide total power by that, then multiply that by the
-- circular cross-section of that planet to get the total power being emitted
-- into that planet, which must equal its emission, allowing you to calculate
-- its surface temperature*
-- * if it had no atmosphere, or albedo
