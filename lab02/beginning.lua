MAX_WHEEL_SPEED = 10
MOVE_STEPS = 10
n_steps = 0

function init()
    n_steps = 0
	robot.leds.set_all_colors("black")
end

function step()
    if n_steps % MOVE_STEPS == 0 then
        robot.wheels.set_velocity(wander())
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
    return robot.random.uniform(10), robot.random.uniform(10)
end
