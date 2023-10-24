class("AnimatedMask", nil, Noble.Transition).extends(Noble.Transition)
local transition = Noble.Transition.AnimatedMask

transition.name = "Animated Mask"
transition.type = Noble.Transition.Type.IN_OUT

function transition:init(__duration, __holdTime, __easeFunction, __imagetable)
	transition.super.init(self, __duration, __holdTime, __easeFunction)
	self.imagetable = __imagetable
end

function transition:draw()
	local progress = self.animator:currentValue()
	local imagetableLength = #self.imagetable
	local index = 1
	if not self.out then
		index = math.clamp((progress * imagetableLength) // 2, 1, imagetableLength)
	else
		index = math.clamp((progress * imagetableLength) // 2, 1, imagetableLength)
	end
	self.imagetable[index]:draw(0, 0)
end