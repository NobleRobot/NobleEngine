--- The existing scene slides off the bottom of the screen, revealing the next scene.

class("SlideOffDown", nil, Noble.Transition).extends(Noble.Transition.SlideOff)
local transition = Noble.Transition.SlideOffDown

transition.name = "Slide Off (Down)"

function transition:init(__duration, __easeFunction)
	transition.super.init(self, __duration, 0, 240, __easeFunction)
end