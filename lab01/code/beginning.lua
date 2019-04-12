-- Put your global variables here

HIGH_VELOCITY = 10
LOW_VELOCITY = 6
VERY_LOW_VELOCITY = 2

PROXIMITY_THRESHOLD = 0.05

NEAR_THE_LIGHT = 0.8 -- change this value accordingly to the light height
UNDER_THE_LIGHT = 1.55 -- change this value accordingly to the light height

DEFAULT_STEPS_RESOLUTION = 5
CRITICAL_STEPS_RESOLUTION = 20

n_steps = 0
steps_resolution = DEFAULT_STEPS_RESOLUTION
move_towards_quadrant = 1 -- arbitrary value the first time ...

--[[ Function executed every time you press the 'execute' button. ]]
function init()
  robot.leds.set_all_colors("black")
end

--[[ Function executed at each time step.
     It must contain the logic of your controller. ]]
function step()
  if n_steps % steps_resolution == 0 then
    max_intensity = 0
    max_light_sensor_index = 1
    light_intensities = total_values_per_quadrant(robot.light)
    proximities = total_values_per_quadrant(robot.proximity)

    if seeing_some_light() then
      priority_quadrants = keys_sorted_by_value(light_intensities, function(a, b) return a > b end)
    elseif contains({1,2}, move_towards_quadrant) then -- was moving forwards
      priority_quadrants = table_concat(shuffle({1,2}), shuffle({3,4})) -- continue to move forwards randomly
    else -- was moving backwards
      priority_quadrants = table_concat(shuffle({3,4}), shuffle({1,2})) -- continue to move backwards randomly
    end

    anti_priority_quadrants = keys_sorted_by_value(proximities, function(a, b) return a > b end)

    if light_intensities[priority_quadrants[1]] >= UNDER_THE_LIGHT then -- stop the robot
      robot.wheels.set_velocity(0, 0)
      log("Under the light :)")
    
    else
      blocked_quadrants = {}
      for i=1,3 do -- don't want to block all 4 quadrants
        if proximities[anti_priority_quadrants[i]] > PROXIMITY_THRESHOLD then 
          table.insert(blocked_quadrants, anti_priority_quadrants[i])
        end
      end
      
      for _, blocked in ipairs(blocked_quadrants) do
        log("Blocking quadrant " .. blocked)
      end

      steps_resolution = DEFAULT_STEPS_RESOLUTION

      for _, best_quadrant in ipairs(priority_quadrants) do
        if not contains(blocked_quadrants, best_quadrant) then
          move_towards_quadrant = best_quadrant
          log("Moving towards quadrant: " .. move_towards_quadrant)
          break
        else -- the preferred way is blocked!
          steps_resolution = CRITICAL_STEPS_RESOLUTION
        end
      end

      if (contains({1,2}, move_towards_quadrant) and (contains(blocked_quadrants, 1) or contains(blocked_quadrants, 2))) 
          or (contains({3,4}, move_towards_quadrant) and (contains(blocked_quadrants, 3) or contains(blocked_quadrants, 3)))
          or light_intensities[priority_quadrants[1]] >= NEAR_THE_LIGHT then
        low_v = VERY_LOW_VELOCITY
        log("Steering sharply...")
      else
        low_v = LOW_VELOCITY
      end

      quadrant_to_velocities = {
        [1] = function () return HIGH_VELOCITY, low_v end,
        [2] = function () return low_v, HIGH_VELOCITY end,
        [3] = function () return -low_v, -HIGH_VELOCITY end,
        [4] = function () return -HIGH_VELOCITY, -low_v end,
      }

      robot.wheels.set_velocity(quadrant_to_velocities[move_towards_quadrant]())
    end
  end
  n_steps = n_steps + 1
end

--[[ Function executed every time you press the 'reset' button in the GUI.
     It is supposed to restore the state of the controller to whatever it was
     right after init() was called. The state of sensors and actuators is
     reset automatically by ARGoS. ]]
function reset()
  n_steps = 0
end

--[[ Function executed only once, when the robot is removed from the simulation. ]]
function destroy()
end

-- My utils

function between(value, min, max)
  if value > min and value < max then return true end
  return false
end

function keys_sorted_by_value(tbl, sortFunc)
  local keys = {}
  for key in pairs(tbl) do table.insert(keys, key) end
  table.sort(keys, function(a,b) return sortFunc(tbl[a], tbl[b]) end)
  return keys
end

function contains (tbl, val)
  for _, value in pairs(tbl) do
    if value == val then
      return true
    end
  end
  return false
end

function shuffle (tbl)
  shuffled = {}
  for i, v in ipairs(tbl) do
    local pos = robot.random.uniform_int(1, #shuffled + 1) -- [min, max)
    table.insert(shuffled, pos, v)
  end
  return shuffled
end

function table_concat(t1,t2)
  for i=1,#t2 do
      t1[#t1+1] = t2[i]
  end
  return t1
end

function total_values_per_quadrant(sensors)
  values = {0,0,0,0}
  for _, sensor in pairs(sensors) do
    if between(sensor.angle, -math.pi/2, 0) then 
      values[1] = values[1] + sensor.value
    elseif between(sensor.angle, 0, math.pi/2) then
      values[2] = values[2] + sensor.value
    elseif between(sensor.angle, math.pi/2, math.pi) then
      values[3] = values[3] + sensor.value
    elseif between(sensor.angle, 0, -math.pi, -math.pi/2) then
      values[4] = values[4] + sensor.value
    end
  end
  return values
end

function seeing_some_light()
  for _, light_sensor in pairs(robot.light) do
    if light_sensor.value > 0 then return true end
  end
  return false
end
