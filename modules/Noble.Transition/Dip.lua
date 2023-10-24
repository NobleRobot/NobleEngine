class("Dip", nil, Noble.Transition).extends(Noble.Transition)
local transition = Noble.Transition.Dip

transition.name = "Dip"
transition.type = Noble.Transition.Type.IN_OUT

function transition:init(__duration,  __holdTime, __panelImage, __easeInFunction, __easeOutFunction, __dither, __x, __y)
	transition.super.init(self, __duration, __holdTime, (__easeInFunction or Ease.outQuad),  (__easeOutFunction or Ease.inQuad))
	self.dither = __dither or Graphics.image.kDitherTypeBayer4x4
	self.panelImage = __panelImage
	self.x = __x or 0
	self.y = __y or 0
end

function transition:draw()
	transition.super.draw(self)
	self.panelImage:drawFaded(self.x, self.y, self.animator:currentValue(), self.dither)
end