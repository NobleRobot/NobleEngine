class("SlideOffLeft", nil, Noble.Transition).extends(Noble.Transition.SlideOff)
local transition = Noble.Transition.SlideOffLeft

transition.name = "Slide Off (Left)"

function transition:init(__duration,  __holdTime, __easeFunction)
	transition.super.init(self, __duration, __holdTime, -400, 0, __easeFunction)
end