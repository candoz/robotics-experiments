MIN_SPEED = -15
MAX_SPEED = 15
STEPS = 20

S = 0.15
W = 0.1
PS_MAX = 0.99
PW_MIN = 0.01
ALPHA = 0.1
BETA = 0.05

current_state = "wandering" -- "wandering", "stopped"
n_steps = 0
left_wheel = 0
right_wheel = 0

function init()
  robot.leds.set_all_colors("black")
end

function step()
  if current_state == "wandering" then
    execute_wander()
  elseif current_state == "stopped" then
    execute_stop()
  else
    log("Unknown state")
  end
  n_steps = n_steps + 1
end

function reset()
end

function destroy()
end

-- What to do in every state:

function execute_wander()
  current_state = "wandering"
  robot.range_and_bearing.set_data(1, 1) -- communicate I'm wondering
  
  if n_steps % STEPS == 0 then
    left_wheel = math.random(MIN_WHEEL_SPEED, MAX_WHEEL_SPEED)
    right_wheel = math.random(MIN_WHEEL_SPEED, MAX_WHEEL_SPEED)
  end
  robot.wheels.set_velocity(left_wheel, right_wheel)
  stop_probability = math.min(PS_MAX, S + ALPHA * count_stopped_neighbours())
  if robot.random() < stop_probability then
    current_state = "stopped"
  end
end

function execute_stop()
  current_state = "stopped"
  robot.range_and_bearing.set_data(1, 0) -- communicate I'm stopped
  robot.wheels.set_velocity(0, 0)
  wander_probability = math.max(PW_MIN, W - BETA * count_stopped_neighbours())
  if math.random() < wander_probability then
    current_state = "wandering"
  end
end

-- My utils:

-- Returns the stopped robots around me
function count_stopped_neighbours()
  n_robot_sensed = 0
  for _, rab in ipairs(robot.range_and_bearing) do
    if rab.range < 30 and rab.data[1] == 1 then
      n_robot_sensed = n_robot_sensed + 1
    end
  end
  return n_robot_sensed
end
