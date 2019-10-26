-- TODO defined globals need to be created somewhere else
export gravitational_constant = 6.6743e-11 -- m^3 / (kg * s^2)
export magic_pressure_constant = 1.1701572e-4 -- s^2 / m^2

parameters = {
  surface_radius: love.math.randomNormal 1100, 5500 -- [1.1e3, 9.9e3  km]
  solid_density: love.math.randomNormal 0.675, 5.2 -- [2.5, 7.9 g/cm^3]
}

parameters.solid_volume = 4/3 * math.pi * parameters.surface_radius^3 -- km^3
parameters.solid_mass = parameters.solid_density * parameters.solid_volume * 1e12 -- kg
parameters.surface_gravity = gravitational_constant * parameters.solid_mass / parameters.surface_radius^2 * 1e-6 -- m/s^2
parameters.atmosphere_reduction_rate = parameters.surface_gravity * magic_pressure_constant -- m^-1
parameters.atmosphere_halving_height = math.log(2) / parameters.atmosphere_reduction_rate -- m
-- volume containing the first half of the entire atmosphere is assumed to be
-- half of the volume of the entire atmosphere if it was at surface pressure
parameters.simulated_atmosphere_volume = (4/3 * math.pi * (parameters.surface_radius + parameters.atmosphere_halving_height / 1000)^3 - parameters.solid_volume) * 2 -- km^3

-- TODO better (based on distance from star / temperature from star)
parameters.surface_atmosphere_pressure = 101325 * math.max 0, love.math.randomNormal 0.125, 0.5 -- [0, 202650 kPa]
-- TODO verify this will generate in meters
parameters.minimum_orbital_height = math.log(1.4e-11 / parameters.surface_atmosphere_pressure) / parameters.atmosphere_reduction_rate -- m
parameters.atmosphere_volume = 4/3 * math.pi * (parameters.surface_radius + parameters.minimum_orbital_height / 1000)^3 - parameters.solid_volume -- km^3
-- TODO atmospheric composition?
-- TODO albedo
-- TODO surface_average_temperature (based on greenhouse gases or lack thereof, albedo, and base temperature from distance to star)

-- unused at this time?
parameters.surface_area = 4 * math.pi * parameters.surface_radius^2
