MAX_WHEEL_SPEED = 10
MOVE_STEPS = 10
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
    wander()
  else
    log("I see the light! ")
    log("Brightest sensor value: " .. get_brightest_light_sensor().value)
  end
end

-- Utils:

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
