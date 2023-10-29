-- A wipe transition using an animated mask in the form of an imagetable.

class("Imagetable", nil, Noble.Transition).extends(Noble.Transition)
local transition = Noble.Transition.Imagetable
transition.name = "Imagetable"

transition.type = Noble.Transition.Type.COVER
transition.drawMode = Graphics.kDrawModeCopy

function transition:setCustomArguments(__arguments)

	self.imagetable = __arguments.imagetable or Graphics.imagetable.new("libraries/noble/assets/images/BetelgeuseTransition")
	self.imagetableOut = __arguments.imagetableOut or self.imagetable

	self.imagetableLength = self.imagetable and #self.imagetable or 0
	self.imagetableOutLength = self.imagetableOut and #self.imagetableOut or 0

	self.color = __arguments.color or Graphics.kColorBlack
	self.invertMask = __arguments.invertMask or false

	self.imagetableReverse = __arguments.imagetableReverse or false
	self.imagetableOutReverse = __arguments.imagetableOutReverse or false

	local sequence0 = (not self.imagetableReverse) and 0 or 1
	local sequence1 = (not self.imagetableReverse) and 1 or 0
	local sequenceOut0 = (not self.imagetableOutReverse) and 0 or 1
	local sequenceOut1 = (not self.imagetableOutReverse) and 1 or 0

	if (self.imagetable == self.imagetableOut) then
		self.sequenceStartValue = sequence0
		self.sequenceMidpointValue = sequence1
		self.sequenceResumeValue = sequence1
		self.sequenceCompleteValue = sequence0
	else
		self.sequenceStartValue = sequence0
		self.sequenceMidpointValue = sequence1
		self.sequenceResumeValue = sequenceOut0
		self.sequenceCompleteValue = sequenceOut1
	end
end

function transition:draw()
	local progress = self.sequence:get()
	local imagetable
	local length
	if not self.holdTimeElapsed then
		imagetable = self.imagetable
		length = self.imagetableLength
	else
		imagetable = self.imagetableOut
		length = self.imagetableOutLength
	end
	local index = math.clamp((progress * length) // 1, 1, length)
	imagetable[index]:draw(0, 0)
end