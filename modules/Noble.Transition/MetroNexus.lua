class("MetroNexus", nil, Noble.Transition).extends(Noble.Transition)
local transition = Noble.Transition.MetroNexus

transition.name = "Metro Nexus"
transition.type = Noble.Transition.Type.IN_OUT

local panels

function transition:init(__duration,  __holdTime)
	transition.super.init(self, __duration, __holdTime, Ease.linear)

	if (panels == nil) then
		panels = {
			Graphics.image.new(80,240, Graphics.kColorWhite),
			Graphics.image.new(80,240, Graphics.kColorWhite),
			Graphics.image.new(80,240, Graphics.kColorWhite),
			Graphics.image.new(80,240, Graphics.kColorWhite),
			Graphics.image.new(80,240, Graphics.kColorWhite)
		}
	end

end

function transition:draw()
	local progress = self.animator:currentValue()
	if not self.out then
		panels[1]:draw(000, (-1 + Ease.outQuint(progress, 0, 1, 1)) * 240 )
		panels[2]:draw(080, (-1 + Ease.outQuart(progress, 0, 1, 1)) * 240 )
		panels[3]:draw(160, (-1 + Ease.outQuart(progress, 0, 1, 1)) * 240 )
		panels[4]:draw(240, (-1 + Ease.outCubic(progress, 0, 1, 1)) * 240 )
		panels[5]:draw(320, (-1 + Ease.outSine (progress, 0, 1, 1)) * 240 )
	else
		local progress2 = 2 - progress
		panels[1]:draw(000, (1 - Ease.inQuint(progress2 - 1, 0, 1, 1)) * -240 + 240)
		panels[2]:draw(080, (1 - Ease.inQuart(progress2 - 1, 0, 1, 1)) * -240 + 240)
		panels[3]:draw(160, (1 - Ease.inQuart(progress2 - 1, 0, 1, 1)) * -240 + 240)
		panels[4]:draw(240, (1 - Ease.inCubic(progress2 - 1, 0, 1, 1)) * -240 + 240)
		panels[5]:draw(320, (1 - Ease.inSine (progress2 - 1, 0, 1, 1)) * -240 + 240)
	end
end

-- class("MetroNexus", nil, Noble.Transition).extends(Noble.Transition)

-- self.name = "Metro Nexus"

-- local panels <const> = {
-- 	Graphics.image.new(80,240, Graphics.kColorWhite),
-- 	Graphics.image.new(80,240, Graphics.kColorWhite),
-- 	Graphics.image.new(80,240, Graphics.kColorWhite),
-- 	Graphics.image.new(80,240, Graphics.kColorWhite),
-- 	Graphics.image.new(80,240, Graphics.kColorWhite)
-- }

-- function Noble.Transition.MetroNexus:draw()
-- 	local progress = self.animator:currentValue()

-- 	if not self.out then
-- 		panels[1]:draw(000, (-1 + math.clamp(progress * 1, 0, 1)) * 240 )
-- 		panels[2]:draw(080, (-1 + math.clamp(progress * 1.5, 0, 1)) * 240 )
-- 		panels[3]:draw(160, (-1 + math.clamp(progress * 2, 0, 1)) * 240 )
-- 		panels[4]:draw(240, (-1 + math.clamp(progress * 2.5, 0, 1)) * 240 )
-- 		panels[5]:draw(320, (-1 + math.clamp(progress * 3, 0, 1)) * 240 )
-- 	else
-- 		panels[1]:draw(000, math.clamp(progress * 1, 0, 1) * -240 + 240)
-- 		panels[2]:draw(080, math.clamp(progress * 1.5, 0, 1) * -240 + 240)
-- 		panels[3]:draw(160, math.clamp(progress * 2, 0, 1) * -240 + 240)
-- 		panels[4]:draw(240, math.clamp(progress * 2.5, 0, 1) * -240 + 240)
-- 		panels[5]:draw(320, math.clamp(progress * 3, 0, 1) * -240 + 240)
-- 	end
-- end
