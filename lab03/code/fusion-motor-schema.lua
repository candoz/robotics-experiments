local vector = require "vector"
local motor_conversions = require "motor_conversions"

PREFERRED_MAX_WHEEL_SPEED = 10
COEFF_RANDOM_AHEAD = 4
COEFF_LIGHT_ATTRACTION = 10

function init()
  n_steps = 0
  robot.leds.set_all_colors("black")
end

function step()
  resultant = vector.vec2_polar_sum(random_ahead(), light_attraction())
  vel_l, vel_r = motor_conversions.vec_to_vels(resultant, robot.wheels.axis_length)
  robot.wheels.set_velocity(vel_l, vel_r)
end

function reset()
end

function destroy()
end

-- Potential fields:

function random_ahead()
  return {
    length = robot.random.uniform(COEFF_RANDOM_AHEAD),
    angle = robot.random.uniform(-math.pi/4, math.pi/4)
  }
end

function light_attraction()
  local sensor = get_sensor_with_highest_value(robot.light)
  local force = 0
  if sensor.value > 0 then 
    force = 1 - sensor.value -- 1 - sigmoid((sensor.value - 0.5) * 3)
  end
  return {
    length = force * COEFF_LIGHT_ATTRACTION,
    angle = sensor.angle
  }
end

-- My utils:

-- Returns true if value higher than min and lower than max, false otherwise.
function between(value, min, max)
  if value > min and value < max then return true end
  return false
end

-- Returns the highest value given a map of sensors, where every sensor has a "value" field
function get_sensor_with_highest_value(sensors)
  highest = nil
  for _, sensor in pairs(sensors) do
    if highest == nil or highest.value < sensor.value then 
      highest = sensor
    end
  end
  return highest
end

function sigmoid(x)
  return 1 / (1 + math.exp(-x))
end
