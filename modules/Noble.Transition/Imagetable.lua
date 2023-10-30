-- A wipe transition using an animated mask in the form of an imagetable.

class("Imagetable", nil, Noble.Transition).extends(Noble.Transition)
local transition = Noble.Transition.Imagetable
transition.name = "Imagetable"

-- Properties
transition._type = Noble.Transition.Type.COVER

-- Override default arguments
transition.ease = Ease.linear

function transition:setCustomArguments(__arguments)

	self.imagetable = __arguments.imagetable
	self.imagetableEnter = __arguments.imagetableEnter or self.imagetable or Graphics.imagetable.new("libraries/noble/assets/images/BoltTransitionEnter")
	self.imagetableExit = __arguments.imagetableExit or self.imagetable or Graphics.imagetable.new("libraries/noble/assets/images/BoltTransitionExit")

	self.reverse = __arguments.reverse or false
	self.reverseEnter = __arguments.reverseEnter or self.reverse
	self.reverseExit = __arguments.reverseExit or self.reverse

	self.flipX = __arguments.flipX or false
	self.flipY = __arguments.flipY or false
	self.flipXEnter = __arguments.flipXEnter or self.flipX or false
	self.flipYEnter = __arguments.flipYEnter or self.flipY or false
	self.flipXExit = __arguments.flipXExit or self.flipX or false
	self.flipYExit = __arguments.flipYExit or self.flipY or false
	self.rotate = __arguments.rotate or false
	self.rotateEnter = __arguments.rotateEnter or self.rotate or false
	self.rotateExit = __arguments.rotateExit or self.rotate or false

	self._frameCountEnter = self.imagetableEnter and #self.imagetableEnter or 0
	self._frameCountExit = self.imagetableExit and #self.imagetableExit or 0

	self._flipValueEnter = Noble.Transition.Imagetable.getFlipValue(self.rotateEnter, self.flipXEnter, self.flipYEnter)
	self._flipValueExit = Noble.Transition.Imagetable.getFlipValue(self.rotateExit, self.flipXExit, self.flipYExit)

	local sequence0 = (not self.reverseEnter) and 0 or 1
	local sequence1 = (not self.reverseEnter) and 1 or 0
	local sequenceExit0 = (not self.reverseExit) and 0 or 1
	local sequenceExit1 = (not self.reverseExit) and 1 or 0

	if (self.imagetableEnter == self.imagetableExit) then
		self._sequenceStartValue = sequence0
		self._sequenceMidpointValue = sequence1
		self._sequenceResumeValue = sequence1
		self._sequenceCompleteValue = sequence0
	else
		self._sequenceStartValue = sequence0
		self._sequenceMidpointValue = sequence1
		self._sequenceResumeValue = sequenceExit0
		self._sequenceCompleteValue = sequenceExit1
	end

	-- Warnings
	if ((__arguments.ease or __arguments.easeEnter or __arguments.easeExit) ~= nil) then
		warn("BONK: You've specified an ease value for an Noble.Transition.Imagetable transition. This will have no effect.")
	end

end

function transition:draw()
	local progress = self.sequence:get()
	local imagetable
	local frameCount
	local flipValue
	if not self.holdTimeElapsed then
		imagetable = self.imagetableEnter
		frameCount = self._frameCountEnter
		flipValue = self._flipValueEnter
	else
		imagetable = self.imagetableExit
		frameCount = self._frameCountExit
		flipValue = self._flipValueExit
	end
	local index = math.clamp((progress * frameCount) // 1, 1, frameCount)
	imagetable[index]:draw(0, 0, flipValue)
end

function Noble.Transition.Imagetable.getFlipValue(__rotate, __flipX, __flipY)
	if(__rotate or (__flipX and __flipY)) then
		return Graphics.kImageFlippedXY
	else
		if(__flipX)		then return Graphics.kImageFlippedX
		elseif(__flipY) then return Graphics.kImageFlippedY end
	end
	return Graphics.kImageUnflipped
end