Noble.Transition = {}
class("Transition", nil, Noble).extends()

Noble.Transition.Type = {}
Noble.Transition.Type.CUT = "Cut"
Noble.Transition.Type.COVER = "Cover"
Noble.Transition.Type.MIX = "Mix"

function Noble.Transition:init(__duration, __holdTime, __arguments)

	self.duration = __duration
	self.holdTime = __holdTime

	self.durationEnter = __arguments.durationEnter or self.duration/2
	self.durationExit = __arguments.durationExit or self.duration/2

	if (__arguments.durationEnter and not __arguments.durationExit) then
		warn("Soft-BONK: You've specified 'durationEnter' but not 'durationExit' for this transition. Thus, 'durationExit' will be half the value of 'duration'. Did you intend to do that?")
	elseif (__arguments.durationExit and not __arguments.durationEnter) then
		warn("Soft-BONK: You've specified 'durationExit' but not 'durationEnter' for this transition. Thus, 'durationEnter' will be half the value of 'duration'. Did you intend to do that?")
	end

	self.sequence = nil

	self._captureScreenshotsDuringTransition = self._captureScreenshotsDuringTransition or false

	self.midpointReached  = false
	self.holdTimeElapsed = false

	-- Arguments
	self.drawMode = __arguments.drawMode or self.drawMode or Graphics.kDrawModeCopy

	if (self._type == Noble.Transition.Type.MIX) then
		self._sequenceStartValue = self._sequenceStartValue or 0
		self._sequenceCompleteValue = self._sequenceCompleteValue or 1

		if ((__arguments.easeEnter or __arguments.easeExit) ~= nil) then
			warn("BONK: You've specified an 'easeEnter' and/or 'easeExit' argument for a transition of type 'Noble.Transition.Type.MIX'. This will have no effect. Use 'ease' instead, or specify a transition of type 'Noble.Transition.Type.COVER'.")
		end
		self.ease = __arguments.ease or self.ease or Ease.linear
		self.oldSceneScreenshot = Utilities.screenshot()
	elseif (self._type == Noble.Transition.Type.COVER) then

		self._sequenceStartValue = self._sequenceStartValue or 0
		self._sequenceMidpointValue = self._sequenceMidpointValue or 1
		self._sequenceResumeValue = self._sequenceResumeValue or 1
		self._sequenceCompleteValue = self._sequenceCompleteValue or 0

		local ease = __arguments.ease or self.ease
		if (ease) then
			self.easeEnter = self.easeEnter or Ease.enter(ease) or ease
			self.easeExit = self.easeExit or Ease.exit(ease) or ease
			if (Ease.enter(ease) or Ease.exit(ease) == nil) then
				warn("Soft-BONK: You've specified an 'ease' value for a transition of type 'Noble.Transition.Type.COVER' that isn't in the form of 'Ease.inOutXxxx' or an 'Ease.outInXxxx'. As a result, this value will be used for both 'easeEnter' and 'easeExit'. Did you mean to do that?")
			end
		else
			self.easeEnter = self.easeEnter or __arguments.easeEnter or Ease.linear
			self.easeExit = self.easeExit or __arguments.easeExit or Ease.linear
		end
	end

	self:setCustomArguments(__arguments)

end

function Noble.Transition:execute()

	local onMidpoint = function()
		Noble.transitionMidpointHandler()
		self.midpointReached = true
		self:onMidpoint()				-- If this transition has any custom code to run here, run it.
	end

	local onHoldTimeElapsed = function()
		self.holdTimeElapsed = true
		self:onHoldTimeElapsed()
	end

	local onComplete = function()
		self:onComplete()				-- If this transition has any custom code to run here, run it.
		Noble.transitionCompleteHandler()
	end

	local type = self._type
	local holdTime = self.holdTime

	if (type == Noble.Transition.Type.CUT) then
		onMidpoint()
		onComplete()
	elseif (type == Noble.Transition.Type.COVER) then
		self.sequence = Sequence.new()
			:from(self._sequenceStartValue)
			:to(self._sequenceMidpointValue, self.durationEnter-(holdTime/2), self.easeEnter)
			:callback(onMidpoint)
			:sleep(holdTime)
			:callback(onHoldTimeElapsed)
			:to(self._sequenceResumeValue, 0)
			:to(self._sequenceCompleteValue, self.durationExit-(holdTime/2), self.easeExit)
			:callback(onComplete)
			:start()
	elseif (type == Noble.Transition.Type.MIX) then
		onMidpoint()
		onHoldTimeElapsed()
		self.sequence = Sequence.new()
			:from(self._sequenceStartValue)
			:to(self._sequenceCompleteValue, self.duration, self.ease)
			:callback(onComplete)
			:start()
	end

end

function Noble.Transition:setCustomArguments(__arguments) end
function Noble.Transition:onMidpoint() end
function Noble.Transition:onHoldTimeElapsed() end
function Noble.Transition:onComplete() end
function Noble.Transition:draw() end

-- Noble Engine built-in transitions.
import 'libraries/noble/modules/Noble.Transition/Cut.lua'
--
import 'libraries/noble/modules/Noble.Transition/CrossDissolve.lua'
import 'libraries/noble/modules/Noble.Transition/Dip.lua'
import 'libraries/noble/modules/Noble.Transition/DipToBlack.lua'
import 'libraries/noble/modules/Noble.Transition/DipToWhite.lua'
--
import 'libraries/noble/modules/Noble.Transition/Imagetable.lua'
import 'libraries/noble/modules/Noble.Transition/ImagetableMask.lua'
import 'libraries/noble/modules/Noble.Transition/Spotlight.lua'
import 'libraries/noble/modules/Noble.Transition/SpotlightMask.lua'
--
import 'libraries/noble/modules/Noble.Transition/SlideOff.lua'
import 'libraries/noble/modules/Noble.Transition/SlideOffLeft.lua'
import 'libraries/noble/modules/Noble.Transition/SlideOffRight.lua'
import 'libraries/noble/modules/Noble.Transition/SlideOffUp.lua'
import 'libraries/noble/modules/Noble.Transition/SlideOffDown.lua'
import 'libraries/noble/modules/Noble.Transition/SlideOn.lua'
import 'libraries/noble/modules/Noble.Transition/SlideOnLeft.lua'
import 'libraries/noble/modules/Noble.Transition/SlideOnRight.lua'
import 'libraries/noble/modules/Noble.Transition/SlideOnUp.lua'
import 'libraries/noble/modules/Noble.Transition/SlideOnDown.lua'
--
import 'libraries/noble/modules/Noble.Transition/MetroNexus.lua'
import 'libraries/noble/modules/Noble.Transition/WidgetSatchel.lua'