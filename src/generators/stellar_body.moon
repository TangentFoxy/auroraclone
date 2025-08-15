-- star.lua
-- LÖVE-compatible Lua module to generate a star and useful derived quantities.
-- No globals are created; require this file and call star.new(...) to get a table.

local star = {}

-- ---------- Physical constants (SI) ----------
local SIGMA_SB = 5.670374419e-8          -- W·m⁻²·K⁻⁴ (Stefan–Boltzmann constant)
local L_SUN    = 3.828e26                -- W       (IAU nominal solar luminosity)
local R_SUN    = 6.957e8                 -- m       (IAU nominal solar radius)
local M_SUN_V  = 4.83                    -- mag     (Sun absolute V magnitude, approx)
local PI       = math.pi
local LN10     = math.log(10)

local function log10(x) return math.log(x)/LN10 end
local function clamp(x, a, b) return math.max(a, math.min(b, x)) end

-- ---------------- Random helpers ----------------
local function random_normal(mean, stddev)
  if love and love.math and love.math.randomNormal then
    return love.math.randomNormal(stddev or 1, mean or 0)
  end
  -- Fallback: Box–Muller transform if LÖVE is not present
  local u1 = math.random()
  local u2 = math.random()
  local z0 = math.sqrt(-2 * math.log(u1)) * math.cos(2 * PI * u2)
  return (z0 * (stddev or 1)) + (mean or 0)
end

local function truncated_normal(mean, stddev, lo, hi, max_tries)
  max_tries = max_tries or 64
  for _=1,max_tries do
    local v = random_normal(mean, stddev)
    if v >= lo and v <= hi then return v end
  end
  -- If repeated draws miss the interval, snap to the nearest bound
  return clamp(mean, lo, hi)
end

-- ------------- Colour / photometry helpers -------------
-- Approximate sRGB for a blackbody at temperature T (K). Range: 1000–40000 K.
local function srgb_from_temperature(T)
  T = clamp(T, 1000, 40000) / 100
  local r, g, b
  if T <= 66 then r = 255 else r = 329.698727446 * ((T - 60) ^ -0.1332047592) end
  if T <= 66 then g = 99.4708025861 * math.log(T) - 161.1195681661
             else g = 288.1221695283 * ((T - 60) ^ -0.0755148492) end
  if T >= 66 then b = 255
  elseif T <= 19 then b = 0
  else b = 138.5177312231 * math.log(T - 10) - 305.0447927307 end
  return clamp(r,0,255)/255, clamp(g,0,255)/255, clamp(b,0,255)/255
end

-- Invert Ballesteros (2012) relation to get B−V from temperature (robust binary search)
-- T(B−V) = 4600 * [ 1/(0.92(B−V)+1.7) + 1/(0.92(B−V)+0.62) ]
local function BV_from_temperature(T)
  local function T_of_BV(BV)
    return 4600 * (1/(0.92*BV + 1.7) + 1/(0.92*BV + 0.62))
  end
  local lo, hi = -0.4, 2.0 -- covers hot/blue to cool/red main-sequence stars
  for _=1,60 do
    local mid = 0.5*(lo+hi)
    if T_of_BV(mid) > T then lo = mid else hi = mid end
  end
  return 0.5*(lo+hi)
end

-- Coarse spectral class from temperature (main-sequence-ish bins)
local function spectral_class(T)
  if     T >= 30000 then return "O"
  elseif T >= 10000 then return "B"
  elseif T >=  7500 then return "A"
  elseif T >=  6000 then return "F"
  elseif T >=  5200 then return "G"
  elseif T >=  3700 then return "K"
  else                    return "M"
  end
end

-- ---------------------- Public API ----------------------

--- Create a star with plausible parameters.
--  options:
--    temperature_mean_K (default 6000), temperature_std_K (1000),
--    temperature_min_K (2000), temperature_max_K (10000), or temperature_K to force a value
--    radius_Rsun (defaults to 1.0 R☉)
--    use_legacy_Mv_fit = true to also compute your original Mv(T) curve as 'absolute_magnitude_fit'
function star.new(options)
  options = options or {}

  local T = options.temperature_K or truncated_normal(
    options.temperature_mean_K or 6000,
    options.temperature_std_K  or 1000,
    options.temperature_min_K  or 2000,
    options.temperature_max_K  or 10000
  )

  local R_Rsun = options.radius_Rsun or 1.0
  local R = R_Rsun * R_SUN

  -- Radiant exitance (power per unit surface area)
  local surface_power_emission = SIGMA_SB * T^4  -- W·m⁻²

  -- Total luminosity and solar-scaled luminosity
  local L = 4 * PI * R^2 * surface_power_emission -- W
  local L_Lsun = L / L_SUN

  -- Absolute V magnitude (toy approximation): M_V = M_{V,☉} − 2.5 log10(L/L_☉)
  local M_V = M_SUN_V - 2.5 * log10(L_Lsun)

  -- Optional: keep your original Mv(T) exponential fit for comparison
  local M_V_fit
  if options.use_legacy_Mv_fit then
    M_V_fit = 35.4631241560502 * math.exp(-0.000353006569939 * T)
  end

  -- Colours
  local BV = BV_from_temperature(T)
  local sr, sg, sb = srgb_from_temperature(T)

  return {
    -- Inputs
    temperature_K = T,
    radius_Rsun   = R_Rsun,

    -- Radiative properties
    surface_power_emission_W_m2 = surface_power_emission, -- σT^4
    luminosity_W   = L,                                    -- 4πR²σT⁴
    luminosity_Lsun = L_Lsun,

    -- Magnitudes / colours
    absolute_magnitude_V = M_V,
    absolute_magnitude_fit = M_V_fit,  -- may be nil if use_legacy_Mv_fit=false
    color_index_BV = BV,
    srgb = { r = sr, g = sg, b = sb },
    spectral_class = spectral_class(T),

    -- Constants exposed for convenience (read-only)
    constants = {
      sigma_sb = SIGMA_SB, L_sun = L_SUN, R_sun = R_SUN, M_sun_V = M_SUN_V
    }
  }
end

--- Irradiance (W·m⁻²) at distance a_m from a source of luminosity L_W.
function star.irradiance_W_m2(L_W, a_m)
  return L_W / (4 * PI * a_m^2)
end

--- Total power intercepted by a planet (W).
--  a_m: orbital radius (m), r_p_m: planet radius (m), albedo: [0..1]
function star.intercepted_power_W(L_W, a_m, r_p_m, albedo)
  albedo = albedo or 0.0
  local flux = star.irradiance_W_m2(L_W, a_m)
  return flux * (1 - albedo) * PI * r_p_m^2
end

--- Equilibrium temperature of a planet (K) neglecting greenhouse.
--  redistribution: "full" (default) emits over 4πR²; "dayside" emits over 2πR²
function star.equilibrium_temperature_K(L_W, a_m, albedo, redistribution)
  albedo = albedo or 0.0
  redistribution = redistribution or "full"
  local f = (redistribution == "dayside") and 2 or 4
  -- Full: σT⁴ = (1−A) * L / (16π a²); Dayside: ... / (8π a²)
  local numer = (1 - albedo) * L_W
  local denom = (4 * f) * PI * SIGMA_SB * a_m^2
  return (numer / denom)^(0.25)
end

return star
