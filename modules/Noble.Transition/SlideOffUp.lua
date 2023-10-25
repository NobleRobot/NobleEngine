--- The existing scene slides off the top of the screen, revealing the next scene.

class("SlideOffUp", nil, Noble.Transition).extends(Noble.Transition.SlideOff)
local transition = Noble.Transition.SlideOffUp

transition.name = "Slide Off (Up)"

function transition:init(__duration, __easeFunction)
	transition.super.init(self, __duration, 0, -240, __easeFunction)
end