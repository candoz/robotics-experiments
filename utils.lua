--[[ Gets the table "tbl" keys ordered by their values using "sortFunc". ]]
function getKeysSortedByValue(tbl, sortFunc)
  local keys = {}
  for key in pairs(tbl) do table.insert(keys,key) end
  table.sort(keys, function(a, b) return sortFunc(tbl[a], tbl[b]) end)
  return keys
end

--[[ Returns true if value is between min and max, false otherwise. ]]
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

function get_sensor_with_highest_value(sensors)
  highest = null
  for _, sensor in pairs(robot.light) do
    if highest == null or sensor.value > highest.value then 
      highest = sensor
    end
  end
  return highest
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
