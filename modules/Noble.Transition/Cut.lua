--- An all-time classic.

class("Cut", nil, Noble.Transition).extends(Noble.Transition)
local transition = Noble.Transition.Cut

transition.name = "Cut"
transition.type = Noble.Transition.Type.CUT

function transition:init(__duration)
	transition.super.init(self, __duration, nil, nil, nil)
end