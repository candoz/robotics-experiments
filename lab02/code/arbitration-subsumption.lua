MAX_WHEEL_SPEED = 10
SLOW_WHEEL_SPEED = 2

PROXIMITY_THRESHOLD = 0.01
SATISFIED_LIGHT_VALUE = 0.35 -- change this value accordingly to the light height

highest_light_sensor = nil
highest_proximity_sensor = nil

function init()
  robot.leds.set_all_colors("black")

end

function step()
  highest_light_sensor = get_sensor_with_highest_value(robot.light)
  highest_proximity_sensor = get_sensor_with_highest_value(robot.proximity)
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
  log("Going straight ahead, full speed!")
end

function follow_the_light() -- otherwise go straight
  if highest_light_sensor.value > 0 then
    if between(highest_light_sensor.angle, math.pi/2, math.pi) then sign_l = -1 else sign_l = 1 end
    if between(highest_light_sensor.angle, -math.pi, -math.pi/2) then sign_r = -1 else sign_r = 1 end
    mod_l = 1 - math.sin(highest_light_sensor.angle)
    mod_r = 1 + math.sin(highest_light_sensor.angle)
    k_norm = MAX_WHEEL_SPEED / math.max(mod_l, mod_r)
    speed_l = sign_l * mod_l * k_norm
    speed_r = sign_r * mod_r * k_norm
    robot.wheels.set_velocity(speed_l, speed_r)
    log("Following the light -> L:" .. math.floor(speed_l*100)/100 .. " R:" .. math.floor(speed_r*100)/100)
  else
    go_straight()
  end
end

function coast_border() -- otherwise follow the light
  if highest_proximity_sensor.value > PROXIMITY_THRESHOLD
      and between(highest_proximity_sensor.angle, math.pi/2, math.pi*7/8)
      and (highest_light_sensor.value == 0 or between(highest_light_sensor.angle, 0, math.pi)) then
    l = 1 + math.cos(highest_proximity_sensor.angle)
    r = 1 - math.cos(highest_proximity_sensor.angle)
    k_norm = MAX_WHEEL_SPEED / math.max(l, r)
    robot.wheels.set_velocity(l * k_norm, r * k_norm)
    log("Coasting a wall on the LEFT -> L:" .. math.floor(l*k_norm*100)/100 .. " R:" .. math.floor(r*k_norm*100)/100)
  elseif highest_proximity_sensor.value > PROXIMITY_THRESHOLD
      and between(highest_proximity_sensor.angle, -math.pi*7/8, -math.pi/2)
      and (highest_light_sensor.value == 0 or between(highest_light_sensor.angle, -math.pi, 0)) then
    l = 1 - math.cos(highest_proximity_sensor.angle)
    r = 1 + math.cos(highest_proximity_sensor.angle)
    k_norm = MAX_WHEEL_SPEED / math.max(l, r)
    robot.wheels.set_velocity(l * k_norm, r * k_norm)
    log("Coasting a wall on the LEFT -> L:" .. math.floor(l*k_norm*100)/100 .. " R:" .. math.floor(r*k_norm*100)/100)
  else
    follow_the_light()
  end
end

function avoid_crash() -- otherwise follow the light
  if highest_proximity_sensor.value > PROXIMITY_THRESHOLD and between(highest_proximity_sensor.angle, 0, math.pi*2) then
    robot.wheels.set_velocity(MAX_WHEEL_SPEED, SLOW_WHEEL_SPEED)
    log("Avoiding an obstacle on the LEFT")
  elseif highest_proximity_sensor.value > PROXIMITY_THRESHOLD and between(highest_proximity_sensor.angle, -math.pi/2, 0) then
    robot.wheels.set_velocity(SLOW_WHEEL_SPEED, MAX_WHEEL_SPEED)
    log("Avoiding an obstacle on the RIGHT")
  else
    follow_the_light()
  end
end

function stand_still() -- otherwise avoid crash
  if highest_light_sensor.value >= SATISFIED_LIGHT_VALUE then
    robot.wheels.set_velocity(0, 0)
    log("Arrived to destination :)")
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
  highest = nil
  for _, sensor in pairs(sensors) do
    if highest == nil or highest.value < sensor.value then 
      highest = sensor
    end
  end
  return highest
end
