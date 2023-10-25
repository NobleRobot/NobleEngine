--- A simple cross-fade.

class("CrossDissolve", nil, Noble.Transition).extends(Noble.Transition)
local transition = Noble.Transition.CrossDissolve

transition.name = "Cross Dissolve"
transition.type = Noble.Transition.Type.OUT

function transition:init(__duration, __holdTime, __easeFunction, __dither)
	transition.super.init(self, __duration, __holdTime, nil, (__easeFunction or Ease.inOutQuart))
	self.dither = __dither or Graphics.image.kDitherTypeBayer4x4
end

function transition:draw()
	self.screenshot:drawFaded(0, 0, self.sequence:get(), self.dither)
end