--- Animation states using a spritesheet/imagetable. Ideal for use with `playdate.graphics.sprite` objects, but suitable for other uses as well.
-- @module Noble.Animation
--

Noble.Animation = {}

--- Setup
-- @section setup

--- Create a new animation "state machine".
-- @string __spritesheet The path to the bitmap spritesheet/imagetable asset. See Playdate SDK docs for imagetable file naming conventions.
-- @return `animation`, a new animation object.
-- @usage
-- MyHero = {}
-- class("MyHero").extends(Graphics.sprite)
--
-- function MyHero:init()
-- 	MyHero.super.init(self)
-- 	-- ...
-- 	self.animation = Noble.Animation.new("assets/images/Hero")
-- 	self.animation:addState("idle", 1, 30)
-- 	self.animation:addState("jump", 31, 34, "float")
-- 	self.animation:addState("float", 35, 45)
-- 	self.animation:addState("turn", 46, 55, "idle")
-- 	self.animation:addState("walk", 56, 65)
-- 	-- ...
-- end
function Noble.Animation.new(__spritesheet)

	local animation = {}

	--- Properties
	-- @section properties

	--- The currently set animation state.
	--
	-- This is intended as `read-only`. You should not modify this property directly.
	-- @see setState
	animation.current = nil

	--- The name of the current animation state. Calling this instead of `animation.current.name` is <em>just</em> a little faster.
	--
	-- This is intended as `read-only`. You should not modify this property directly.
	animation.currentName = nil

	--- The current frame of the animation. This is the index of the imagetable, not the frame of the current state.
	--
	-- Most of the time, you should not modify this directly, although you can if you're feeling saucy and are prepared for unpredictable results.
	-- @see draw
	animation.currentFrame = 1

	--- This controls the flipping of the image when drawing. DIRECTION_RIGHT is unflipped, DIRECTION_LEFT is flipped on the X axis.
	-- @usage
	-- function MyHero:goLeft()
	-- 	self.animation.direction = Noble.Animation.DIRECTION_LEFT
	-- 	-- ...
	-- end
	animation.direction = Noble.Animation.DIRECTION_RIGHT

	--- This animation's spritesheet. You can replace this with another `playdate.graphics.imagetable` object, but generally you would not want to.
	-- @see new
	animation.imageTable = Graphics.imagetable.new(__spritesheet)

	local empty = true

	--- Setup
	-- @section setup

	--- Add an animation state. The first state added will be the default set for this animation.
	--
	-- NOTE: Added states are first-degree member objects of your Noble.Animation object, so do not use names of already existing methods/properties ("current", "draw", etc.).
	-- @string __name The name of the animation, this is also used as the key for the animation.
	-- @int __startFrame This is the first frame for this animation in the imagetable/spritesheet
	-- @int __endFrame This is the first frame for this animation in the imagetable/spritesheet
	-- @string[optional] __next By default, animation states will loop, but if you want to sequence an animation, enter the name of the next state here.
	-- @usage
	--	-- You can reference an animation's state's properties using bog-standard lua syntax:
	--
	--	animation.idle.endFrame			-- 30
	--	animation.walk.endFrame			-- 65
	--	animation.["walk"].endFrame		-- 65
	--	animation.jump.name				-- "jump"
	--	animation.jump.next				-- "float"
	--	animation.idle.next				-- nil
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

	--- Methods
	-- @section methods

	--- Sets the current animation state. This can be run in a object's `update` method because it only changes the animation state if the new state is different from the current one.
	-- @tparam string|Noble.Animation __animationState The name of the animation to set. You can pass the name of the state, or the object itself.
	-- @bool[opt=false] __continuous Set to true if your new state's frames line up with the previous one's, i.e.: two walk cycles but one is wearing a cute hat!
	-- @tparam string|Noble.Animation __unlessThisState If this state is the current state, do not set the new one.
	-- @usage animation:setState("walk")
	-- @usage animation:setState(animation.walk)
	-- @usage
	--	animation:setState(animation.walkNoHat)
	--	--
	--	animation:setState(animation.walkYesHat, true)
	-- @usage
	--	function MyHero:update()
	--		-- Input
	--		-- ...
	--
	--		-- Physics/collisions
	--		-- ...
	--
	--		-- Animation states
	--		if (grounded) then
	--			if (turning) then
	--				self.animation:setState(self.animation.turn)
	--			elseif (math.abs(self.velocity.x) > 15) then
	--				self.animation:setState(self.animation.walk, false, self.animation.turn)
	--			else
	--				self.animation:setState(self.animation.idle, false, self.animation.turn)
	--			end
	--		else
	--			self.animation:setState(self.animation.jump, false, self.animation.float)
	--		end
	--
	--		groundedLastFrame = grounded
	--	end
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
	--
	-- The ideal place for this is in a `playdate.graphics.sprite:draw()` for characters and items, or @{NobleScene:update|NobleScene:update} for basic graphical scene objects.
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

	--- Sometimes, you just want to draw a specific frame.
	-- Use this for objects or sprites that you want to control outside of update loops, such as score counters, flipbook-style objects that respond to player input, etc.
	-- @int __frameNumber The frame to draw from the current state. This is not an imagetable index. Entering `1` will draw the selected state's `startFrame`.
	-- @string[opt=self.currentName] __stateName The specific state to pull the __frameNumber from.
	-- @number[opt=0] __x
	-- @number[opt=0] __y
	-- @param[opt=self.direction] __direction Override the current direction.
	function animation:drawFrame(__frameNumber, __stateName, __x, __y, __direction)
		local x = __x or 0
		local y = __y or 0
		local stateName = __stateName or self.currentName
		local direction = __direction or self.direction
		local frameNumber = self[stateName].startFrame - 1 + __frameNumber
		self.imageTable:drawImage(frameNumber, x, y, direction)
	end

	return animation
end

--- Constants
-- @section constants

--- A re-contextualized instance of `playdate.graphics.kImageUnflipped`
Noble.Animation.DIRECTION_RIGHT = Graphics.kImageUnflipped
--- A re-contextualized instance of `playdate.graphics.kImageFlippedX`
Noble.Animation.DIRECTION_LEFT = Graphics.kImageFlippedX