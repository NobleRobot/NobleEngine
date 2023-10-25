--- The existing scene slides off the screen, revealing the next scene.

class("SlideOff", nil, Noble.Transition).extends(Noble.Transition)
local transition = Noble.Transition.SlideOff

transition.name = "Slide Off"
transition.type = Noble.Transition.Type.OUT

function transition:init(__duration, __toX, __toY, __easeFunction)
	transition.super.init(self, __duration, 0, nil, (__easeFunction or Ease.inQuart))
	self.toX = __toX
	self.toY = __toY
end

function transition:draw()
	transition.super.draw(self)
	local progress = self.sequence:get()
	self.screenshot:draw(
		self.toX * (1 - progress),
		self.toY * (1 - progress)
	)
end