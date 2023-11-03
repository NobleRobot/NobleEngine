--- A simple cross-fade.
-- @submodule Noble.Transition

class("CrossDissolve", nil, Noble.Transition).extends(Noble.Transition)
local transition = Noble.Transition.CrossDissolve
transition.name = "Cross Dissolve"

-- Type
transition._type = Noble.Transition.Type.MIX

--- Transition properties.
-- @see Noble.transition
-- @see Noble.Transition.setDefaultProperties
transition.defaultProperties = {
	ease = Ease.outCubic,
	dither = Graphics.image.kDitherTypeBayer4x4
}

function transition:setProperties(__properties)
	self.dither = __properties.dither or self.defaultProperties.dither
end

function transition:draw()
	self.oldSceneScreenshot:drawFaded(0, 0, 1 - self.sequence:get(), self.dither)
end