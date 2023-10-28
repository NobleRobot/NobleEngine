--- A simple cross-fade.

class("CrossDissolve", nil, Noble.Transition).extends(Noble.Transition)
local transition = Noble.Transition.CrossDissolve
transition.name = "Cross Dissolve"

transition.type = Noble.Transition.Type.MIX
transition.ease = Ease.inOutCubic

function transition:setCustomArguments(__arguments)
	self.dither = __arguments.dither or Graphics.image.kDitherTypeBayer4x4
end

function transition:draw()
	self.oldSceneScreenshot:drawFaded(0, 0, 1 - self.sequence:get(), self.dither)
end