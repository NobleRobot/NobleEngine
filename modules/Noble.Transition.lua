Noble.Transition = {}
class("Transition", nil, Noble).extends()

Noble.Transition.Type = {}
Noble.Transition.Type.CUT = "Cut"
Noble.Transition.Type.COVER = "Cover"
Noble.Transition.Type.MIX = "Mix"

local inOutQuad		= {	easeIn = Ease.inQuad,		easeOut = Ease.outQuad		}
local inOutCubic	= {	easeIn = Ease.inCubic,		easeOut = Ease.outCubic		}
local inOutQuart	= {	easeIn = Ease.inQuart,		easeOut = Ease.outQuart		}
local inOutQuint	= {	easeIn = Ease.inQuint,		easeOut = Ease.outQuint		}
local inOutSine		= {	easeIn = Ease.inSine,		easeOut = Ease.outSine		}
local inOutExpo		= {	easeIn = Ease.inExpo,		easeOut = Ease.outExpo		}
local inOutCirc		= {	easeIn = Ease.inCirc,		easeOut = Ease.outCirc		}
local inOutElastic	= {	easeIn = Ease.inElastic,	easeOut = Ease.outElastic	}
local inOutBack		= {	easeIn = Ease.inBack,		easeOut = Ease.outBack		}
local inOutBounce	= {	easeIn = Ease.inBounce,		easeOut = Ease.outBounce	}

local outInQuad		= { easeOut = Ease.inQuad,		easeIn = Ease.outQuad		}
local outInCubic	= { easeOut = Ease.inCubic,		easeIn = Ease.outCubic		}
local outInQuart	= { easeOut = Ease.inQuart,		easeIn = Ease.outQuart		}
local outInQuint	= { easeOut = Ease.inQuint,		easeIn = Ease.outQuint		}
local outInSine		= { easeOut = Ease.inSine,		easeIn = Ease.outSine		}
local outInExpo		= { easeOut = Ease.inExpo,		easeIn = Ease.outExpo		}
local outInCirc		= { easeOut = Ease.inCirc,		easeIn = Ease.outCirc		}
local outInElastic	= { easeOut = Ease.inElastic,	easeIn = Ease.outElastic	}
local outInBack		= { easeOut = Ease.inBack,		easeIn = Ease.outBack		}
local outInBounce	= { easeOut = Ease.inBounce,	easeIn = Ease.outBounce		}

local eases	= {
	[Ease.inOutQuad] = inOutQuad,
	[Ease.inOutCubic] = inOutCubic,
	[Ease.inOutQuart] = inOutQuart,
	[Ease.inOutQuint] = inOutQuint,
	[Ease.inOutSine] = inOutSine,
	[Ease.inOutExpo] = inOutExpo,
	[Ease.inOutCirc] = inOutCirc,
	[Ease.inOutElastic] = inOutElastic,
	[Ease.inOutBack] = inOutBack,
	[Ease.inOutBounce] = inOutBounce,
	[Ease.outInQuad] = outInQuad,
	[Ease.outInCubic] = outInCubic,
	[Ease.outInQuart] = outInQuart,
	[Ease.outInQuint] = outInQuint,
	[Ease.outInSine] = outInSine,
	[Ease.outInExpo] = outInExpo,
	[Ease.outInCirc] = outInCirc,
	[Ease.outInElastic] = outInElastic,
	[Ease.outInBack] = outInBack,
	[Ease.outInBounce] = outInBounce
}

function Noble.Transition:init(__duration, __holdTime, __arguments)

	self.duration = __duration
	self.holdTime = __holdTime

	self.sequence = nil

	self.captureScreenshotsDuringTransition = self.captureScreenshotsDuringTransition or false

	self.midpointReached = false
	self.holdTimeElapsed = false

	-- Arguments
	self.drawMode = __arguments.drawMode or self.drawMode or Graphics.kDrawModeCopy

	if (self.type == Noble.Transition.Type.MIX) then
		self.sequenceStartValue = self.sequenceStartValue or 0
		self.sequenceCompleteValue = self.sequenceCompleteValue or 1

		if ((__arguments.easeIn or __arguments.easeOut) ~= nil) then
			warn("BONK: You've specified an 'easeIn' and/or 'easeOut' argument for a transition of type 'Noble.Transition.Type.MIX'. This will have no effect. Use 'ease' instead, or specify a transition of type 'Noble.Transition.Type.COVER'.")
		end
		self.ease = __arguments.ease or self.ease or Ease.linear
		self.oldSceneScreenshot = Utilities.screenshot()
	elseif (self.type == Noble.Transition.Type.COVER) then

		self.duration *= 2

		self.sequenceStartValue = self.sequenceStartValue or 0
		self.sequenceMidpointValue = self.sequenceMidpointValue or 1
		self.sequenceResumeValue = self.sequenceResumeValue or 1
		self.sequenceCompleteValue = self.sequenceCompleteValue or 0

		local ease = __arguments.ease or self.ease
		if (ease) then
			self.easeIn = self.easeIn or (eases[ease] or {}).easeIn or ease
			self.easeOut = self.eastOut or (eases[ease] or {}).easeOut or ease
			if (eases[ease] == nil and ease ~= Ease.linear) then
				warn("Soft-BONK: You've specified an 'ease' value for a transition of type 'Noble.Transition.Type.COVER' that isn't 'inOutXxxx' or 'outInXxxx'. Did you mean to do that?")
			end
		else
			self.easeIn = __arguments.easeIn or self.easeIn or Ease.linear
			self.easeOut = __arguments.easeOut or self.easeOut or Ease.linear
		end
	end

	-- setDefaultCustomArgumentValues()??
	self:setCustomArguments(__arguments)

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
import 'libraries/noble/modules/Noble.Transition/Imagetable.lua'
import 'libraries/noble/modules/Noble.Transition/ImagetableMask.lua'
--
import 'libraries/noble/modules/Noble.Transition/Dip.lua'
import 'libraries/noble/modules/Noble.Transition/DipToBlack.lua'
import 'libraries/noble/modules/Noble.Transition/DipToWhite.lua'
--
import 'libraries/noble/modules/Noble.Transition/SlideOff.lua'
import 'libraries/noble/modules/Noble.Transition/SlideOffLeft.lua'
import 'libraries/noble/modules/Noble.Transition/SlideOffRight.lua'
import 'libraries/noble/modules/Noble.Transition/SlideOffUp.lua'
import 'libraries/noble/modules/Noble.Transition/SlideOffDown.lua'
--
import 'libraries/noble/modules/Noble.Transition/SlideOn.lua'
import 'libraries/noble/modules/Noble.Transition/SlideOnLeft.lua'
import 'libraries/noble/modules/Noble.Transition/SlideOnRight.lua'
import 'libraries/noble/modules/Noble.Transition/SlideOnUp.lua'
import 'libraries/noble/modules/Noble.Transition/SlideOnDown.lua'
import 'libraries/noble/modules/Noble.Transition/Spotlight.lua'
--
import 'libraries/noble/modules/Noble.Transition/MetroNexus.lua'
import 'libraries/noble/modules/Noble.Transition/WidgetSatchel.lua'