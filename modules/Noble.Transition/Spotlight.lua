---
-- @submodule Noble.Transition

class("Spotlight", nil, Noble.Transition).extends(Noble.Transition)
local transition = Noble.Transition.Spotlight
transition.name = "Spotlight"

-- Type
transition._type = Noble.Transition.Type.COVER

--- A spotlight in-out transition.
-- @see Noble.Transition.SpotlightMask.defaultProperties
-- @table Noble.Transition.Spotlight.defaultProperties
-- @number[opt=0.25] holdTime
-- @tparam Graphics.image panelImage
-- @tparam[opt=Graphics.image.kDitherTypeBayer4x4] Graphics.image.kDither dither
-- @tparam[opt=Ease.outInQuad] Ease ease
-- @number[opt=200] x
-- @number[opt=120] y
-- @tparam[opt=nil] Ease easeEnter
-- @number[opt=nil] xEnter
-- @number[opt=nil] yEnter
-- @number[opt=nil] xEnterStart
-- @number[opt=nil] yEnterStart
-- @number[opt=nil] xEnterEnd
-- @number[opt=nil] yEnterEnd
-- @tparam[opt=nil] Ease easeEnter
-- @number[opt=nil] xExit
-- @number[opt=nil] yExit
-- @number[opt=nil] xExitStart
-- @number[opt=nil] yExitStart
-- @number[opt=nil] xExitEnd
-- @number[opt=nil] yExitEnd
transition.defaultProperties = {
	holdTime = 0.25,
	panelImage = nil,
	dither = Graphics.image.kDitherTypeBayer4x4,
	ease = Ease.outInQuad,
	x = 200,
	y = 120,
	easeEnter = nil,
	xEnter = nil,
	yEnter = nil,
	xEnterStart = nil,
	yEnterStart = nil,
	xEnterEnd = nil,
	yEnterEnd = nil,
	easeExit = nil,
	xExit = nil,
	yExit = nil,
	xExitStart = nil,
	yExitStart = nil,
	xExitEnd = nil,
	yExitEnd = nil
}

-- "Static" variables
local defaultPanelImage

function transition:setProperties(__arguments)
	if (defaultPanelImage == nil) then defaultPanelImage = Graphics.image.new(400,240, Graphics.kColorBlack) end
	self.panelImage = __arguments.panelImage or self.defaultProperties.panelImage or defaultPanelImage
	self.dither = __arguments.dither or self.defaultProperties.dither
	self.x = __arguments.x or self.defaultProperties.x
	self.y = __arguments.y or self.defaultProperties.y

	self.xEnter = __arguments.xEnter or self.defaultProperties.xEnter or self.x
	self.yEnter = __arguments.yEnter or self.defaultProperties.yEnter or self.y
	self.xEnterStart = __arguments.xEnterStart or self.defaultProperties.xEnterStart or self.xEnter
	self.yEnterStart = __arguments.yEnterStart or self.defaultProperties.yEnterStart or self.yEnter
	self.xEnterEnd = __arguments.xEnterEnd or self.defaultProperties.xEnterEnd or self.xEnter
	self.yEnterEnd = __arguments.yEnterEnd or self.defaultProperties.yEnterEnd or self.yEnter

	self.xExit = __arguments.xExit or self.defaultProperties.xExit or self.x
	self.yExit = __arguments.yExit or self.defaultProperties.yExit or self.y
	self.xExitStart = __arguments.xExitStart or self.defaultProperties.xExitStart or self.xExit
	self.yExitStart = __arguments.yExitStart or self.defaultProperties.yExitStart or self.yExit
	self.xExitEnd = __arguments.xExitEnd or self.defaultProperties.xExitEnd or self.xExit
	self.yExitEnd = __arguments.yExitEnd or self.defaultProperties.yExitEnd or self.yExit
end

function transition:draw()
	local progress = self.sequence:get()
	self.panelImage:drawFaded(0, 0, progress, self.dither)
	Graphics.setColor(Graphics.kColorClear)
	if (not self.midpointReached) then
		Graphics.fillCircleAtPoint(
			math.lerp(self.xEnterStart, self.xEnterEnd, progress),
			math.lerp(self.yEnterStart, self.yEnterEnd, progress),
			(1 - progress) * 233
		)
	else
		Graphics.fillCircleAtPoint(
			math.lerp(self.xExitStart, self.xExitEnd, progress),
			math.lerp(self.yExitStart, self.yExitEnd, progress),
			(1 - progress) * 233
		)
	end
	Graphics.setColor(Graphics.kColorBlack)
end