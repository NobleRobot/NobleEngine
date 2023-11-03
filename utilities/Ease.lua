--- Extensions to `playdate.easingFunctions`, aliased as `Ease` in Noble Engine.
-- See the Playdate SDK for a list of easing functions.
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
	[Ease.outInQuad]	= {		enter = Ease.outQuad,		exit = Ease.inQuad		},
	[Ease.outInCubic]	= {		enter = Ease.outCubic,		exit = Ease.inCubic		},
	[Ease.outInQuart]	= {		enter = Ease.outQuart,		exit = Ease.inQuart		},
	[Ease.outInQuint]	= {		enter = Ease.outQuint,		exit = Ease.inQuint		},
	[Ease.outInSine]	= {		enter = Ease.outSine,		exit = Ease.inSine		},
	[Ease.outInExpo]	= {		enter = Ease.outExpo,		exit = Ease.inExpo		},
	[Ease.outInCirc]	= {		enter = Ease.outCirc,		exit = Ease.inCirc		},
	[Ease.outInElastic]	= {		enter = Ease.outElastic,	exit = Ease.inElastic	},
	[Ease.outInBack]	= {		enter = Ease.outBack,		exit = Ease.inBack		},
	[Ease.outInBounce]	= {		enter = Ease.outBounce,		exit = Ease.inBounce	},
	[Ease.linear]		= {		enter = Ease.linear,		exit = Ease.linear		}
}

local reverseFunctions = {
	[Ease.inQuad]		= Ease.outQuad,
	[Ease.inCubic]		= Ease.outCubic,
	[Ease.inQuart]		= Ease.outQuart,
	[Ease.inQuint]		= Ease.outQuint,
	[Ease.inSine]		= Ease.outSine,
	[Ease.inExpo]		= Ease.outExpo,
	[Ease.inCirc]		= Ease.outCirc,
	[Ease.inElastic]	= Ease.outElastic,
	[Ease.inBack]		= Ease.outBack,
	[Ease.inBounce]		= Ease.outBounce,
	[Ease.outQuad]		= Ease.inQuad,
	[Ease.outCubic]		= Ease.inCubic,
	[Ease.outQuart]		= Ease.inQuart,
	[Ease.outQuint]		= Ease.inQuint,
	[Ease.outSine]		= Ease.inSine,
	[Ease.outExpo]		= Ease.inExpo,
	[Ease.outCirc]		= Ease.inCirc,
	[Ease.outElastic]	= Ease.inElastic,
	[Ease.outBack]		= Ease.inBack,
	[Ease.outBounce]	= Ease.inBounce,
	[Ease.linear]		= Ease.linear
}

--- Returns the first half of an "inOut" or "outIn" easing function.
-- Returns `nil` for any easing function that isn't in the form of `Ease.inOutXxxx` or `Ease.outInXxxx`. `Ease.linear` returns itself.
-- @usage
-- local ease = Ease.outInQuad
-- local easeEnter = Ease.enter(ease)	-- Returns "Ease.outQuad"
function Ease.enter(__easingFunction)
	if (componentFunctions[__easingFunction] == nil) then return nil end
	return componentFunctions[__easingFunction].enter
end

--- Returns the second half of an "inOut" or "outIn" easing function.
-- Returns `nil` for any easing function that isn't in the form of `Ease.inOutXxxx` or `Ease.outInXxxx`. `Ease.linear` returns itself.
-- @usage
-- local ease = Ease.outInQuad
-- local easeExit = Ease.exit(ease)		-- Returns "Ease.inQuad"
function Ease.exit(__easingFunction)
	if (componentFunctions[__easingFunction] == nil) then return nil end
	return componentFunctions[__easingFunction].exit
end

--- Returns the reverse function of the provided function.
-- Returns `nil` for any easing function that isn't in the form of `Ease.inXxxx` or `Ease.outXxxx`. `Ease.linear` returns itself.
-- @usage
-- local ease = Ease.inQuad
-- local reverseEase = Ease.reverse(ease) -- Returns "Ease.outQuad"
function Ease.reverse(__easingFunction)
	if (reverseFunctions[__easingFunction] == nil) then return nil end
	return reverseFunctions[__easingFunction]
end