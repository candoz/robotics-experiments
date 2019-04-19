local vector = require "vector"
local motor_conversions = require "motor_conversions"

PREFERRED_MAX_WHEEL_SPEED = 10
PROXIMITY_DANGER = 0.5

COEFF_RANDOM_AHEAD = 3
COEFF_LIGHT_ATTRACTION = 5
COEFF_OBSTACLE_REPULSION = 5
COEFF_OBSTACLE_TANGENTIAL = 8

function init()
  n_steps = 0
  robot.leds.set_all_colors("black")
end

function step()
  res1 = vector.vec2_polar_sum(random_ahead(), light_attraction())
  res2 = vector.vec2_polar_sum(obstacle_repulsion(), obstacle_tangential())
  res = vector.vec2_polar_sum(res1, res2)
  vel_l, vel_r = motor_conversions.vec_to_vels(res, robot.wheels.axis_length)
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
  local mod = 0
  if sensor.value > 0 then 
    mod = 1 - sensor.value -- 1 - sigmoid((sensor.value - 0.5) * 3)
  end
  return {
    length = mod * COEFF_LIGHT_ATTRACTION,
    angle = sensor.angle
  }
end

function obstacle_repulsion()
  local sensor = get_sensor_with_highest_value(robot.proximity)
  local mod = 0
  if sensor.value > PROXIMITY_DANGER then
    mod = sensor.value * COEFF_OBSTACLE_REPULSION
  end
  return {
    length = mod,
    angle = sensor.angle + math.pi
  }
end

function obstacle_tangential()
  local sensor = get_sensor_with_highest_value(robot.proximity)
  return {
    length = sensor.value * COEFF_OBSTACLE_TANGENTIAL,
    angle = sensor.angle + math.pi/2 -- avoiding to the left
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
