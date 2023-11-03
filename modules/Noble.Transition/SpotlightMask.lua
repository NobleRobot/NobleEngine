--- A circle wipe transition.
-- @see Noble.Transition.Spotlight
-- @submodule Noble.Transition

class("SpotlightMask", nil, Noble.Transition).extends(Noble.Transition)
local transition = Noble.Transition.SpotlightMask
transition.name = "Spotlight Mask"

-- Type
transition._type = Noble.Transition.Type.MIX

--- Transition properties.
-- @see Noble.transition
-- @see Noble.Transition.setDefaultProperties
transition.defaultProperties = {
	ease = Ease.outQuad,
	panelImage = nil, -- Defined as a local var below
	dither = Graphics.image.kDitherTypeBayer4x4,
	x = 200,
	y = 120,
	xStart = nil,
	yStart = nil,
	xEnd = nil,
	yEnd = nil,
	invert = false
}

function transition:setProperties(__arguments)
	self.x = __arguments.x or self.defaultProperties.x
	self.y = __arguments.y or self.defaultProperties.y
	self.xStart = __arguments.xStart or self.defaultProperties.xStart or self.x
	self.yStart = __arguments.yStart or self.defaultProperties.yStart or self.y
	self.xEnd = __arguments.xEnd or self.defaultProperties.xEnd or self.x
	self.yEnd = __arguments.yEnd or self.defaultProperties.yEnd or self.y

	self.invert = __arguments.invert or self.defaultProperties.invert

	if (self.invert) then
		self.ease = Ease.reverse(self.ease)
	end

	-- "Private" variables
	self._maskBackground = nil
	self._maskForegroundDrawMode = nil
	if (self.invert ~= true) then
		self._maskBackground = Graphics.image.new(400, 240, Graphics.kColorWhite)
		self._maskForegroundDrawMode = Graphics.kDrawModeFillBlack
	else
		self._maskBackground = Graphics.image.new(400, 240, Graphics.kColorBlack)
		self._maskForegroundDrawMode = Graphics.kDrawModeFillWhite
	end

	self._startRadius = math.max(
		Geometry.distanceToPoint(self.xStart, self.yStart, 0, 0),
		Geometry.distanceToPoint(self.xStart, self.yStart, 400, 0),
		Geometry.distanceToPoint(self.xStart, self.yStart, 400, 240),
		Geometry.distanceToPoint(self.xStart, self.yStart, 0, 240)
	)
	self._endRadius = math.max(
		Geometry.distanceToPoint(self.xEnd, self.yEnd, 0, 0),
		Geometry.distanceToPoint(self.xEnd, self.yEnd, 400, 0),
		Geometry.distanceToPoint(self.xEnd, self.yEnd, 400, 240),
		Geometry.distanceToPoint(self.xEnd, self.yEnd, 0, 240)
	)

end

function transition:draw()
	local progress = self.sequence:get()

	if (not self.invert) then
		self.oldSceneScreenshot:draw(0, 0)
		Graphics.setColor(Graphics.kColorClear)
		Graphics.fillCircleAtPoint(
			math.lerp(self.xStart, self.xEnd, progress),
			math.lerp(self.yStart, self.yEnd, progress),
			progress * self._endRadius
		)
		Graphics.setColor(Graphics.kColorBlack)
	else
		local mask = Graphics.image.new(400, 240, Graphics.kColorBlack)
		Graphics.pushContext(mask)
			Graphics.setColor(Graphics.kColorWhite)
			Graphics.fillCircleAtPoint(
				math.lerp(self.xStart, self.xEnd, progress),
				math.lerp(self.yStart, self.yEnd, progress),
				(1 - progress) * self._startRadius
			)
		Graphics.popContext()
		self.oldSceneScreenshot:setMaskImage(mask)
		self.oldSceneScreenshot:draw(0, 0)
	end

end