local utils = require("utils")

MAX_WHEEL_SPEED = 10

function init()
  robot.leds.set_all_colors("black")
end

function step()
  avoid_crash() -- otherwise follow the light, or go straight if you're in the dark ...
end

function reset()
  robot.wheels.set_velocity(0,0)
  n_steps = 0
  robot.leds.set_all_colors("black")
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
    light_direction = get_brightest_light_sensor().angle
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
