DEFAULT_STEPS_RESOLUTION = 10
MAX_WHEEL_SPEED = 10
MAX_PROXIMITIES_AHEAD = 4 -- 3 sensors to the top-left, 3 sensors to the top-right
n_steps = 0
steps_resolution = 5

function init()
  n_steps = 0
  robot.leds.set_all_colors("black")
end

function step()
  if n_steps % steps_resolution == 0 then
    steps_resolution = DEFAULT_STEPS_RESOLUTION
    avoid_obstacle()
  end
  n_steps = n_steps + 1
end

function reset()
  robot.wheels.set_velocity(0,0)
  n_steps = 0
  robot.leds.set_all_colors("black")
end

--[[ This function is executed only once, when the robot is removed from the simulation ]]
function destroy()
  -- put your code here
end


-- Behaviours:

function wander()
  log("I'm wandering in the dark :(")
  steps_resolution = 20 -- make it wander a little... trying to avoid Brownian motion
  robot.wheels.set_velocity(robot.random.uniform(10), robot.random.uniform(10))
end

function follow_the_light()
  if not seeing_some_light() then
    wander()
  else
    light_direction = get_brightest_light_sensor().angle
    if between(light_direction, math.pi/2, math.pi) then sign_l = -1 else sign_l = 1 end
    if between(light_direction, math.pi, math.pi*3/2) then sign_r = -1 else sign_r = 1 end
    mod_l = 1 - math.sin(light_direction)
    mod_r = 1 + math.sin(light_direction)
    k_norm = MAX_WHEEL_SPEED / math.max(mod_l, mod_r)
    speed_l = sign_l * mod_l * k_norm
    speed_r = sign_r * mod_r * k_norm
    robot.wheels.set_velocity(speed_l, speed_r)
  end
end

function avoid_obstacle()
  if not sensing_obstacles_ahead() then
    follow_the_light()
  else
    left_proximities, right_proximities = get_proximities_left_right()
    total_proximities_ahead = left_proximities + right_proximities
    delta = total_proximities_ahead * (MAX_WHEEL_SPEED/2) / MAX_PROXIMITIES_AHEAD -- normalizing total value
    slow_wheel_speed = MAX_WHEEL_SPEED/2 - delta
    fast_wheel_speed = MAX_WHEEL_SPEED/2 + delta
    if left_proximities > right_proximities then
      log("Trying to avoid an obstacle on the LEFT.. delta = " .. total_proximities_ahead)
      robot.wheels.set_velocity(fast_wheel_speed, slow_wheel_speed)
    else
      log("Trying to avoid an obstacle on the RIGHT.. delta = " .. total_proximities_ahead)
      robot.wheels.set_velocity(slow_wheel_speed, fast_wheel_speed)
    end
  end
end


-- Utils:

function between(value, min, max)
  if value > min and value < max then return true end
  return false
end

function seeing_some_light()
  for _, light_sensor in pairs(robot.light) do
    if light_sensor.value > 0 then return true end
  end
  return false
end

function get_brightest_light_sensor()
  brightest = null
  for _, light_sensor in pairs(robot.light) do
    if brightest == null or light_sensor.value >= brightest.value then 
      brightest = light_sensor
    end
  end
  return brightest
end

function sensing_obstacles_ahead()
  for _, proximity_sensor in pairs(robot.proximity) do
    value = proximity_sensor.value
    angle = proximity_sensor.angle
    if value > 0 and between(angle, -math.pi/2, math.pi/2) then 
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
