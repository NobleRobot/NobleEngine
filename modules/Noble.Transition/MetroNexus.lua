--- A "cascade" wipe transition, taken from "Metro Nexus" by Noble Robot.
-- @submodule Noble.Transition

class("MetroNexus", nil, Noble.Transition).extends(Noble.Transition)
local transition = Noble.Transition.MetroNexus
transition.name = "Metro Nexus"

-- Type
transition._type = Noble.Transition.Type.COVER

-- Overrides
transition._sequenceResumeValue = 0
transition._sequenceCompleteValue = 1
transition.easeEnter = Ease.linear
transition.easeExit = Ease.linear

-- "Static" variables
local panels

function transition:setProperties(__arguments)

	if (panels == nil) then
		panels = {
			Graphics.image.new(80,240, Graphics.kColorWhite),
			Graphics.image.new(80,240, Graphics.kColorWhite),
			Graphics.image.new(80,240, Graphics.kColorWhite),
			Graphics.image.new(80,240, Graphics.kColorWhite),
			Graphics.image.new(80,240, Graphics.kColorWhite)
		}
	end

	-- Warnings
	if (__arguments.easeEnter or __arguments.easeEnter or __arguments.ease) then
		warn("BONK: 'Noble.Transition.MetroNexus' does not support custom ease values.")
	end

end

function transition:draw()
	local progress = self.sequence:get()
	if (not self.holdTimeElapsed) then
		panels[1]:draw(000, (-1 + Ease.outQuint(progress, 0, 1, 1)) * 240)
		panels[2]:draw(080, (-1 + Ease.outQuart(progress, 0, 1, 1)) * 240)
		panels[3]:draw(160, (-1 + Ease.outQuart(progress, 0, 1, 1)) * 240)
		panels[4]:draw(240, (-1 + Ease.outCubic(progress, 0, 1, 1)) * 240)
		panels[5]:draw(320, (-1 + Ease.outSine (progress, 0, 1, 1)) * 240)
	else
		panels[1]:draw(000,  (1 - Ease.inQuint(progress, 0, 1, 1)) * -240 + 240)
		panels[2]:draw(080,  (1 - Ease.inQuart(progress, 0, 1, 1)) * -240 + 240)
		panels[3]:draw(160,  (1 - Ease.inQuart(progress, 0, 1, 1)) * -240 + 240)
		panels[4]:draw(240,  (1 - Ease.inCubic(progress, 0, 1, 1)) * -240 + 240)
		panels[5]:draw(320,  (1 - Ease.inSine (progress, 0, 1, 1)) * -240 + 240)
	end
end
