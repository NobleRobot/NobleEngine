---
-- @submodule Noble.Transition

class("DipTile", nil, Noble.Transition).extends(Noble.Transition)
local transition = Noble.Transition.DipTile
transition.name = "DipTile"

-- Type
transition._type = Noble.Transition.Type.COVER

--- Fade to a tiled color, then to the next scene.
-- @table Noble.Transition.Dip.defaultProperties
-- @number[opt=0.25] holdTime
-- @tparam Graphics.image tilePattern
-- @tparam[opt=Graphics.image.kDitherTypeBayer4x4] Graphics.image.kDither dither
-- @tparam[opt=Ease.outInQuad] Ease ease
-- @number[opt=0] x
-- @number[opt=0] y
transition.defaultProperties = {
	holdTime = 0.25,
	ease = Ease.outInQuad,
	dither = Graphics.image.kDitherTypeBayer4x4,
	tilePattern = nil,
	x = 0,
	y = 0
}

function transition:setProperties(__arguments)
	self.dither = __arguments.dither or self.defaultProperties.dither
	self.tilePattern = __arguments.tilePattern or self.defaultProperties.tilePattern
	self.x = __arguments.x or self.defaultProperties.x
	self.y = __arguments.y or self.defaultProperties.y
end

function transition:draw()
	self.tilePattern:fadedImage(self.sequence:get(), self.dither)
		:drawTiled(self.x, self.y, 400, 240)
end