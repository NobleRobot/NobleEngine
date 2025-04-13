--- An abstract class from which transition types are extended.
-- @module Noble.Transition

Noble.Transition = {}
class("Transition", nil, Noble).extends()

Noble.Transition.Type = {}

--- A transition type where no time at all passes between scenes.
-- @see Noble.Transition.Cut
Noble.Transition.Type.CUT = "Cut"

--- A transition type that has an "Enter" phase and an "Exit" phase. The new scene does not become active until the Enter phase is complete. A "holdTime" value determines how long to wait after the Enter phase completes before starting the Exit phase.
-- @see Noble.Transition.Dip
-- @see Noble.Transition.Imagetable
-- @see Noble.Transition.Spotlight
Noble.Transition.Type.COVER = "Cover"

--- A transition type that takes a screenshot of the exiting scene and activates the new scene before beginning the transition, allowing for both scenes to appear to be visible during the transition.
-- @see Noble.Transition.CrossDissolve
-- @see Noble.Transition.SlideOff
-- @see Noble.Transition.ImagetableMask
Noble.Transition.Type.MIX = "Mix"

--- A transition may have unique properties that can be set by the user when invoked. This table holds the default values for those properties.
-- @see setDefaultProperties
Noble.Transition.defaultProperties = {}

function Noble.Transition:init(__duration, __arguments)

	self.duration = __duration or Noble.getConfig().defaultTransitionDuration

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

	self.drawMode = self.drawMode or __arguments.drawMode or Graphics.kDrawModeCopy

	self.holdTime = self.holdTime or __arguments.holdTime or self.defaultProperties.holdTime or 0

	-- If the transition duration is so short that it breaks the sequence, we pad
	-- out the time so that it takes at least one frame on either side. This is a
	-- failsafe mostly in place for runtime-calculated transition durations. No one
	-- would ever set a transition duration that short on purpose... right?
	local frameDuration = 1/playdate.getFPS()
	if ((self.durationEnter - self.holdTime/2) < frameDuration) then
		self.durationEnter = frameDuration + self.holdTime/2 + 0.001
	end
	if ((self.durationExit - self.holdTime/2) < frameDuration) then
		self.durationEnter = frameDuration + self.holdTime/2 + 0.001
	end

	if (self._type == Noble.Transition.Type.MIX) then

		self._sequenceStartValue = self._sequenceStartValue or 0
		self._sequenceCompleteValue = self._sequenceCompleteValue or 1

		self.ease = self.ease or __arguments.ease or self.defaultProperties.ease or Ease.linear
		if ((__arguments.easeEnter or __arguments.easeExit) ~= nil) then
			warn("BONK: You've specified an 'easeEnter' and/or 'easeExit' argument for a transition of type 'Noble.Transition.Type.MIX'. This will have no effect. Use 'ease' instead, or specify a transition of type 'Noble.Transition.Type.COVER'.")
		end

		self.oldSceneScreenshot = Utilities.screenshot()

	elseif (self._type == Noble.Transition.Type.COVER) then

		self._sequenceStartValue = self._sequenceStartValue or 0
		self._sequenceMidpointValue = self._sequenceMidpointValue or 1
		self._sequenceResumeValue = self._sequenceResumeValue or 1
		self._sequenceCompleteValue = self._sequenceCompleteValue or 0

		local ease = self.ease or __arguments.ease or self.defaultProperties.ease or Ease.linear
		if (ease) then
			self.easeEnter = self.easeEnter or self.defaultProperties.easeEnter or Ease.enter(ease) or ease
			self.easeExit = self.easeExit or self.defaultProperties.easeExit or Ease.exit(ease) or ease
			if (Ease.enter(ease) == nil or Ease.exit(ease) == nil) then
				warn("Soft-BONK: You've specified an 'ease' value for a transition of type 'Noble.Transition.Type.COVER' that isn't in the form of 'Ease.inOutXxxx' or an 'Ease.outInXxxx'. As a result, this value will be used for both 'easeEnter' and 'easeExit'. Did you mean to do that?")
			end
		else
			self.easeEnter = self.easeEnter or __arguments.easeEnter or self.defaultProperties.easeEnter or self.easeEnter or Ease.linear
			self.easeExit = self.easeExit or __arguments.easeExit or self.defaultProperties.easeExit or self.easeExit or Ease.linear
		end

	end

	self:setProperties(__arguments)

end

--- Use this to modify multiple default properties of a transition. Having default properties avoids having to set them every time a transition is called.
-- Properties added here are merged with the existing default properties table. Overwrites only happen when a new value is set.
-- @usage
-- Noble.Transition.setDefaultProperties(Noble.Transition.CrossDissolve, {
-- 	dither = Graphics.image.kDitherTypeDiagonalLine
-- 	ease = Ease.outQuint
-- })
-- Noble.Transition.setDefaultProperties(Noble.Transition.SpotlightMask, {
-- 	x = 325,
-- 	y = 95,
-- 	invert = true
-- })
-- @see defaultProperties
function Noble.Transition.setDefaultProperties(__transition, __properties)
	table.merge(__transition.defaultProperties, __properties)
end

function Noble.Transition:execute()

	local onStart = function()
		Noble.transitionStartHandler()
		self:onStart()					-- If this transition has any custom code to run here, run it.
	end

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

	if (type == Noble.Transition.Type.CUT or self.duration <= 0) then
		onStart()
		onMidpoint()
		onHoldTimeElapsed()
		onComplete()
	elseif (type == Noble.Transition.Type.COVER) then
		onStart()
		local durationEnterCalculated = self.durationEnter-(holdTime/2)
		if (durationEnterCalculated <= 0) then
			durationEnterCalculated = 0
		end
		local durationExitCalculated = self.durationExit-(holdTime/2)
		if (durationExitCalculated <= 0) then
			durationExitCalculated = 0
		end
		self.sequence = Sequence.new()
			:from(self._sequenceStartValue)
			:to(self._sequenceMidpointValue, durationEnterCalculated, self.easeEnter)
			:callback(onMidpoint)
			:sleep(holdTime)
			:callback(onHoldTimeElapsed)
			:to(self._sequenceResumeValue, 0)
			:to(self._sequenceCompleteValue, durationExitCalculated, self.easeExit)
			:callback(onComplete)
			:start()
	elseif (type == Noble.Transition.Type.MIX) then
		onStart()
		onMidpoint()
		onHoldTimeElapsed()
		self.sequence = Sequence.new()
			:from(self._sequenceStartValue)
			:to(self._sequenceCompleteValue, self.duration, self.ease)
			:callback(onComplete)
			:start()
	end

end

--- *Do not call this directly.* Implement this in a custom transition in order to set properties from user arguments given in `Noble.transition()`. See existing transitions for implementation examples.
-- @see Noble.transition
function Noble.Transition:setProperties(__arguments) end

--- *Do not call this directly.* Implement this in a custom transition in order to run custom code when the transition starts. Default transitions in Noble Engine do not use this.
function Noble.Transition:onStart() end

--- *Do not call this directly.* Implement this in a custom transition in order to run custom code when the transition reaches its midpoint. Default transitions in Noble Engine do not use this.
function Noble.Transition:onMidpoint() end

--- *Do not call this directly.* Implement this in a custom transition in order to run custom code when the transition's hold time has elapsed. Default transitions in Noble Engine do not use this.
function Noble.Transition:onHoldTimeElapsed() end

--- *Do not call this directly.* Implement this in a custom transition in order to run custom code when the transition completes. Default transitions in Noble Engine do not use this.
function Noble.Transition:onComplete() end

--- *Do not call this directly.* Implement this in a custom transition to draw the transition. This runs once per frame while the transition is running. See existing transitions for implementation examples.
function Noble.Transition:draw() end


-- Noble Engine built-in transitions.
import 'libraries/noble/modules/Noble.Transition/Cut.lua'
--
import 'libraries/noble/modules/Noble.Transition/CrossDissolve.lua'
import 'libraries/noble/modules/Noble.Transition/Dip.lua'
import 'libraries/noble/modules/Noble.Transition/DipTile.lua'
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