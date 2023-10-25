--- The existing scene slides off the left side of the screen, revealing the next scene.

class("SlideOffLeft", nil, Noble.Transition).extends(Noble.Transition.SlideOff)
local transition = Noble.Transition.SlideOffLeft

transition.name = "Slide Off (Left)"

function transition:init(__duration, __easeFunction)
	transition.super.init(self, __duration, -400, 0, __easeFunction)
end