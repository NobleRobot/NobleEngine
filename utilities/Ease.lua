--- Extensions to `playdate.easingFunctions`, aliased as `Ease` in Noble Engine.
-- @module Ease

local componentFunctions = {
	[Ease.inOutQuad]	= {		enter = Ease.inQuad,		exit = Ease.outQuad		},
	[Ease.inOutCubic]	= {		enter = Ease.inCubic,		exit = Ease.outCubic	},
	[Ease.inOutQuart]	= {		enter = Ease.inQuart,		exit = Ease.outQuart	},
	[Ease.inOutQuint]	= {		enter = Ease.inQuint,		exit = Ease.outQuint	},
	[Ease.inOutSine]	= {		enter = Ease.inSine,		exit = Ease.outSine		},
	[Ease.inOutExpo]	= {		enter = Ease.inExpo,		exit = Ease.outExpo		},
	[Ease.inOutCirc]	= {		enter = Ease.inCirc,		exit = Ease.outCirc		},
	[Ease.inOutElastic]	= {		enter = Ease.inElastic,		exit = Ease.outElastic	},
	[Ease.inOutBack]	= {		enter = Ease.inBack,		exit = Ease.outBack		},
	[Ease.inOutBounce]	= {		enter = Ease.inBounce,		exit = Ease.outBounce	},
	[Ease.outInQuad]	= { 	enter = Ease.outQuad,		exit = Ease.inQuad		},
	[Ease.outInCubic]	= { 	enter = Ease.outCubic,		exit = Ease.inCubic		},
	[Ease.outInQuart]	= { 	enter = Ease.outQuart,		exit = Ease.inQuart		},
	[Ease.outInQuint]	= { 	enter = Ease.outQuint,		exit = Ease.inQuint		},
	[Ease.outInSine]	= { 	enter = Ease.outSine,		exit = Ease.inSine		},
	[Ease.outInExpo]	= { 	enter = Ease.outExpo,		exit = Ease.inExpo		},
	[Ease.outInCirc]	= { 	enter = Ease.outCirc,		exit = Ease.inCirc		},
	[Ease.outInElastic]	= { 	enter = Ease.outElastic,	exit = Ease.inElastic	},
	[Ease.outInBack]	= { 	enter = Ease.outBack,		exit = Ease.inBack		},
	[Ease.outInBounce]	= { 	enter = Ease.outBounce,		exit = Ease.inBounce	},
	[Ease.linear]		= {		enter = Ease.linear,		exit = Ease.linear		}
}

--- Component Functions
--- Use these methods to quickly retrieve one of the two "halves" of an "inOut" or "outIn" easing function.
--- Returns `nil` for any easing function that isn't in the form of `Ease.inOutXxxx` or `Ease.outInXxxx`. `Ease.linear` returns itself. See the Playdate SDK for a list of easing functions.
--- Useful when you don't know until runtime which ease is going to be used, or when splitting up an ease across multiple animations (such as in Noble.Transition).
-- @usage
-- local ease = Ease.outInQuad
-- local easeEnter = Ease.enter(ease)	-- Returns "Ease.outQuad"
-- local easeExit = Ease.exit(ease)		-- Returns "Ease.inQuad"
-- @section componentFunctions

---
function Ease.enter(__easingFunction)
	if (componentFunctions[__easingFunction] == nil) then return nil end
	return componentFunctions[__easingFunction].enter
end

---
function Ease.exit(__easingFunction)
	if (componentFunctions[__easingFunction] == nil) then return nil end
	return componentFunctions[__easingFunction].exit
end