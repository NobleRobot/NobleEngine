--- Fade to white, then to the next scene.
-- @submodule Noble.Transition

class("DipToWhite", nil, Noble.Transition).extends(Noble.Transition.Dip)
local transition = Noble.Transition.DipToWhite
transition.name = "Dip to White"

transition.panelImage = Graphics.image.new(400, 240, Graphics.kColorWhite)

function transition:setCustomArguments(__arguments)
	transition.super.setCustomArguments(self, __arguments)
	--self.panelImage = panel
	self.x = 0
	self.y = 0
end