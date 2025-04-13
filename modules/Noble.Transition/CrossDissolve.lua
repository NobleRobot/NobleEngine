---
-- @submodule Noble.Transition

class("CrossDissolve", nil, Noble.Transition).extends(Noble.Transition)
local transition = Noble.Transition.CrossDissolve
transition.name = "Cross Dissolve"

-- Type
transition._type = Noble.Transition.Type.MIX

--- A simple cross-fade.
-- @table Noble.Transition.CrossDissolve.defaultProperties
-- @tparam[opt=Ease.outCubic] Ease ease
-- @tparam[opt=Graphics.image.kDitherTypeBayer4x4] Graphics.image.kDither dither
transition.defaultProperties = {
	ease = Ease.outCubic,
	dither = Graphics.image.kDitherTypeBayer4x4
}

transition.tilePattern = Graphics.image.new(8, 8, Graphics.kColorBlack)

function transition:setProperties(__properties)
	self.dither = __properties.dither or self.defaultProperties.dither
	self.oldSceneScreenshot:addMask(true)
end

function transition:draw()
	self.oldSceneScreenshot:clearMask(1)
	Graphics.lockFocus(self.oldSceneScreenshot:getMaskImage())
	self.tilePattern:fadedImage(self.sequence:get(), self.dither)
		:drawTiled(0, 0, 400, 240)
	Graphics.unlockFocus()
	self.oldSceneScreenshot:draw(0, 0)
end