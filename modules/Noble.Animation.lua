--- Animation states using a spritesheet/imagetable. Ideal for use with `playdate.graphics.sprite` objects, but suitable for other uses as well.
-- @module Noble.Animation
--

Noble.Animation = {}

--- Setup
-- @section setup

--- Create a new animation "state machine".
-- @string __spritesheet The path to the bitmap spritesheet/imagetable asset.
-- @return `animation`, a new animation object.
function Noble.Animation.new(__spritesheet)

	local animation = {}
	animation.imageTable = Graphics.imagetable.new(__spritesheet)
	animation.currentFrame = 1
	animation.current = nil
	animation.currentName = nil

	animation.direction = Noble.Animation.DIRECTION_RIGHT

	local empty = true

	--- Add an animation state. The first state added will be the default set for this animation.
	-- @string __name The name of the animation, this is also used as the key for the animation.
	-- @int __startFrame This is the first frame for this animation in the imagetable/spritesheet
	-- @int __endFrame This is the first frame for this animation in the imagetable/spritesheet
	-- @string[optional] __next By default, animation states will loop, but if you want to sequence an animation, enter the name of the next animation here.
	function animation:addState(__name, __startFrame, __endFrame, __next)

		self[__name] = {
			name = __name,
			startFrame = __startFrame,
			endFrame = __endFrame,
			next = __next
		}

		-- Set this animation state as default if it is the first one added.
		if (empty == true) then
			empty = false
			self.currentFrame = __startFrame
			self.current = self[__name]
			self.currentName = __name
		end

	end

	--- Changes
	-- @tparam string|Noble.Animation __animationState The name of the animation to set. You can pass the name of the state, or the object itself.
	-- @bool[opt=false] __continuous Set to true if your new state's frames line up with the previous one's, i.e.: two walk cycles but one is wearing a cute hat!
	-- @tparam string|Noble.Animation __unlessThisState If this state is the current state, do not set the new one.
	-- @usage animation:setState("run")
	-- @usage animation:setState(animation.run)
	-- @usage
	--	animation:setState(animation.walkNoHat)
	--	--
	--	animation:setState(animation.walkYesHat, true)
	function animation:setState(__animationState, __continuous, __unlessThisState)

		if (__unlessThisState ~= nil) then
			if (type(__unlessThisState) == "string") then
				if (self.currentName == __unlessThisState) then return end
			elseif (type(__unlessThisState) == "table") then
				if (self.current == __unlessThisState) then return end
			end
		end

		local newState = nil

		if (type(__animationState) == "string") then
			if (self.currentName == __animationState) then return end
			newState = self[__animationState]
			self.currentName = __animationState
		elseif (type(__animationState) == "table") then
			if (self.current == __animationState) then return end
			newState = __animationState
			self.currentName = __animationState.name
		end

		local continuous = __continuous or false

		if (continuous) then
			local localFrame = self.currentFrame - self.current.startFrame
			self.currentFrame = newState.startFrame + localFrame
		else
			self.currentFrame = newState.startFrame
		end

		self.current = newState
	end

	--- Draw the current frame.
	-- @number[opt=0] __x
	-- @number[opt=0] __y
	-- @bool[opt=true] __advance Advances to the next frame after drawing this one.
	-- @usage
	--	function MySprite:draw()
	--		animation:draw()
	--	end
	-- @usage
	--	function MyScene:update()
	--		animation:draw(100,100)
	--	end
	function animation:draw(__x, __y, __advance)

		if(self.currentFrame < self.current.startFrame or self.currentFrame > self.current.endFrame + 1) then
			self.currentFrame = self.current.startFrame
		elseif(self.currentFrame == self.current.endFrame + 1) then
			if (self.current.next ~= nil) then
				self:setState(self.current.next) -- Goes to next animation state.
			end
			self.currentFrame = self.current.startFrame -- Loop animation state. (TO-DO: account for continuous somehow?)
		end

		local x = __x or 0
		local y = __y or 0
		self.imageTable:drawImage(self.currentFrame, x, y, self.direction)

		local advance = __advance or true
		if (advance) then
			self.currentFrame = self.currentFrame + 1
		end

		--previousAnimationName = self.currentName
	end

	return animation
end

--- Constants
-- @section constants

--- A re-contextualized Graphics.kImageUnflipped
Noble.Animation.DIRECTION_RIGHT = Graphics.kImageUnflipped
--- A re-contextualized Graphics.kImageFlippedX
Noble.Animation.DIRECTION_LEFT = Graphics.kImageFlippedX