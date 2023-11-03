-- A wipe transition using an animated mask in the form of an imagetable.
-- @submodule Noble.Transition

class("ImagetableMask", nil, Noble.Transition).extends(Noble.Transition)
local transition = Noble.Transition.ImagetableMask
transition.name = "Imagetable Mask"

-- Type
transition._type = Noble.Transition.Type.MIX

-- Overrides
transition.ease = Ease.linear

--- Transition properties.
-- @see Noble.transition
-- @see Noble.Transition.setDefaultProperties
transition.defaultProperties = {
	imagetable = Graphics.imagetable.new("libraries/noble/assets/images/BoltTransitionEnter"),
	reverse = false,
	flipX = false,
	flipY = false,
	rotate = false,
	hasTransparency = true,
	invert = false
}

function transition:setProperties(__properties)

	self.imagetable = __properties.imagetable or self.defaultProperties.imagetable
	self.reverse = __properties.reverse or self.defaultProperties.reverse
	self.flipX = __properties.flipX or self.defaultProperties.flipX
	self.flipY = __properties.flipY or self.defaultProperties.flipY
	self.rotate = __properties.rotate or self.defaultProperties.rotate
	self.hasTransparency = __properties.hasTransparency or self.defaultProperties.hasTransparency
	self.invert = __properties.invert or self.defaultProperties.invert

	-- "Private" variables
	self._flipValue = Noble.Transition.Imagetable.getFlipValue(self.rotate, self.flipX, self.flipY)
	self._imagetableLength = self.imagetable and #self.imagetable or 0
	self._maskBackground = nil
	self._maskForegroundDrawMode = nil
	if (self.invert ~= true) then
		self._maskBackground = Graphics.image.new(400, 240, Graphics.kColorWhite)
		self._maskForegroundDrawMode = Graphics.kDrawModeFillBlack
	else
		self._maskBackground = Graphics.image.new(400, 240, Graphics.kColorBlack)
		self._maskForegroundDrawMode = Graphics.kDrawModeFillWhite
	end

	-- Warnings
	if (__properties.imagetableExit ~= nil) then
		warn("BONK: You've specified an 'imagetableExit' for an Noble.Transition.ImagetableMask transition. This will have no effect. ")
	end
	if ((__properties.ease or __properties.easeEnter or __properties.easeExit) ~= nil) then
		warn("BONK: You've specified an ease value for an Noble.Transition.ImagetableMask transition. This will have no effect.")
	end

end

function transition:draw()
	local progress = self.sequence:get()
	local length = self._imagetableLength
	local index = math.clamp((progress * length) // 1, 1, length)
	local mask = Graphics.image.new(400, 240)

	Graphics.pushContext(mask)
		Graphics.setImageDrawMode(Graphics.kDrawModeCopy)
		self._maskBackground:draw(0,0)
		if (self.hasTransparency) then Graphics.setImageDrawMode(self._maskForegroundDrawMode) end
		self.imagetable[index]:draw(0,0, self._flipValue)
	Graphics.popContext()

	self.oldSceneScreenshot:setMaskImage(mask)
	self.oldSceneScreenshot:draw(0,0)

end