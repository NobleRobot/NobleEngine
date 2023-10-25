--- The existing scene slides off the right side of the screen, revealing the next scene.

class("SlideOffRight", nil, Noble.Transition).extends(Noble.Transition.SlideOff)
local transition = Noble.Transition.SlideOffRight

transition.name = "Slide Off (Right)"

function transition:init(__duration, __easeFunction)
	transition.super.init(self, __duration, 400, 0, __easeFunction)
end