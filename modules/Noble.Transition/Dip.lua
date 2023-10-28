class("Dip", nil, Noble.Transition).extends(Noble.Transition)
local transition = Noble.Transition.Dip

transition.name = "Dip"
transition.type = Noble.Transition.Type.COVER

function transition:setCustomArguments(__arguments)
	self.dither = __arguments.dither or Graphics.image.kDitherTypeBayer4x4
	self.panelImage = __arguments.panelImage
	self.x = __arguments.x or 0
	self.y = __arguments.y or 0
end

function transition:draw()
	transition.super.draw(self)
	self.panelImage:drawFaded(self.x, self.y, self.sequence:get(), self.dither)
end