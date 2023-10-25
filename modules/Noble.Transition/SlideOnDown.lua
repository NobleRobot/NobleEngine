class("SlideOnDown", nil, Noble.Transition).extends(Noble.Transition)
local transition = Noble.Transition.SlideOnDown

transition.name = "Slide On (Down)"

function transition:init(__duration, __easeFunction)
	transition.super.init(self, __duration, 0, -240, __easeFunction)
end