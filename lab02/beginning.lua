MAX_WHEEL_SPEED = 10
MOVE_STEPS = 10
PROXIMITY_THRESHOLD = 0.5
n_steps = 0

function init()
  n_steps = 0
  robot.leds.set_all_colors("black")
end

function step()
  if n_steps % MOVE_STEPS == 0 then
    follow_the_light()
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
  robot.wheels.set_velocity(robot.random.uniform(10), robot.random.uniform(10))
end

function follow_the_light()
  if not seeing_some_light() then
    log("I'm in the dark :(")
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
    if value >= PROXIMITY_THRESHOLD and ( angle > math.pi/4 and angle < math.pi*3/4 ) then 
      return true 
    end
  end
  return false
end
