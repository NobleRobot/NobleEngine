class("SlideOff", nil, Noble.Transition).extends(Noble.Transition)
local transition = Noble.Transition.SlideOff

transition.name = "Slide Off"
transition.type = Noble.Transition.Type.OUT

function transition:init(__duration,  __holdTime, __toX, __toY, __easeFunction)
	transition.super.init(self, __duration, __holdTime, nil, (__easeFunction or Ease.inQuart))
	self.toX = __toX
	self.toY = __toY
end

function transition:draw()
	transition.super.draw(self)
	self.screenshot:draw(
		self.toX * (1 - self.animator:currentValue()),
		self.toY * (1 - self.animator:currentValue())
	)
end