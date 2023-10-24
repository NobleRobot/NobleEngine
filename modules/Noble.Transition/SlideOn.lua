class("SlideOn", nil, Noble.Transition).extends(Noble.Transition)
local transition = Noble.Transition.SlideOn

transition.name = "Slide On"
transition.type = Noble.Transition.Type.OUT

function transition:init(__duration,  __holdTime, __fromX, __fromY, __easeFunction)
	transition.super.init(self, __duration, __holdTime, nil, (__easeFunction or Ease.outQuart))
	self.fromX = __fromX
	self.fromY = __fromY
end

function transition:draw()
	transition.super.draw(self)
	self.screenshot:draw(
		self.fromX * (1 - self.animator:currentValue()),
		self.fromY * (1 - self.animator:currentValue())
	)
end