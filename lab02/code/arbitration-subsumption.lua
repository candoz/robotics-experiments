MAX_WHEEL_SPEED = 10
SLOW_WHEEL_SPEED = 2
PROXIMITY_THRESHOLD = 0.05
SATISFIED_LIGHT_VALUE = 0.35 -- change this value accordingly to the light height

function init()
  robot.leds.set_all_colors("black")
end

function step()
  stand_still() -- this naming upsets me deeply ...
end

function reset()
  robot.wheels.set_velocity(0,0)
end

function destroy()
end

-- Behaviours:

function go_straight()
  robot.wheels.set_velocity(MAX_WHEEL_SPEED, MAX_WHEEL_SPEED)
end

function follow_the_light() -- otherwise go straight
  if not seeing_some_light() then
    go_straight()
  else
    light_direction = get_sensor_with_highest_value(robot.light).angle
    if between(light_direction, math.pi/2, math.pi) then sign_l = -1 else sign_l = 1 end
    if between(light_direction, -math.pi, -math.pi/2) then sign_r = -1 else sign_r = 1 end
    mod_l = 1 - math.sin(light_direction)
    mod_r = 1 + math.sin(light_direction)
    k_norm = MAX_WHEEL_SPEED / math.max(mod_l, mod_r)
    speed_l = sign_l * mod_l * k_norm
    speed_r = sign_r * mod_r * k_norm
    robot.wheels.set_velocity(speed_l, speed_r)
  end
end

function avoid_crash() -- otherwise follow the light
  if not sensing_obstacles_ahead(PROXIMITY_THRESHOLD) then
    follow_the_light()
  else
    left_proximities, right_proximities = get_proximities_left_right()

    if left_proximities > right_proximities then
      log("Trying to avoid an obstacle on the LEFT")
      robot.wheels.set_velocity(MAX_WHEEL_SPEED, SLOW_WHEEL_SPEED)
    else
      log("Trying to avoid an obstacle on the RIGHT")
      robot.wheels.set_velocity(SLOW_WHEEL_SPEED, MAX_WHEEL_SPEED)
    end
  end
end

function stand_still()
  if get_sensor_with_highest_value(robot.light).value >= SATISFIED_LIGHT_VALUE then
    robot.wheels.set_velocity(0, 0)
    log("Arrived :)")
  else
    avoid_crash()
  end
end

-- My utils:

-- Returns true if value higher than min and lower than max, false otherwise.
function between(value, min, max)
  if value > min and value < max then return true end
  return false
end

-- Returns the highest value given a map of sensors, where every sensor has a "value" field
function get_sensor_with_highest_value(sensors)
  highest = null
  for _, sensor in pairs(sensors) do
    if highest == null or highest.value < sensor.value then 
      highest = sensor
    end
  end
  return highest
end

-- Returns true if the robot has at least a light sensor value higher than the threshold
function seeing_some_light()
  for _, sensor in pairs(robot.light) do
    if sensor.value > 0 then return true end
  end
  return false
end

-- Returns true if at least one proximity sensor 
function sensing_obstacles_ahead(threshold)
  for _, sensor in pairs(robot.proximity) do
    if sensor.value > threshold and between(sensor.angle, -math.pi/2, math.pi/2) then 
      return true 
    end
  end
  return false
end

--[[ Returns a couple of values (left, right) with the total proximities values for
the sensors positioned top-left and top-right respectively ]]
function get_proximities_left_right()
  left = 0
  right = 0
  for _, proximity_sensor in pairs(robot.proximity) do
    value = proximity_sensor.value
    angle = proximity_sensor.angle
    if between(angle, 0, math.pi/2) then
      left = left + value
    elseif between(angle, -math.pi/2, 0) then
      right = right + value
    end
  end
  return left, right
end
