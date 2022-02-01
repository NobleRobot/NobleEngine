---
-- An extention of Playdate's sprite object, incorporating `Noble.Animation` and other Noble Engine features.
-- Use this in place of `playdate.graphics.sprite` in most cases.
--
-- `NobleSprite` is a child class of `playdate.graphics.sprite`, so see the Playdate SDK documentation for additional methods and properties.
--
-- @classmod NobleSprite
--

NobleSprite = {}
class("NobleSprite").extends(Graphics.sprite)

--- Do not call an "init" method directly. Use `NobleSprite()` (see usage examples).
-- @string[opt] __imageOrSpritesheet The path to the image or spritesheet asset that this NobleSprite will use for its view.
-- @bool[opt=false] __animated Set this to `true` in order to use Noble.Animation.
-- @bool[opt=false] __singleState If this sprite has just one animation, set this to true. It saves you from having to use Noble.Anmiation.addState()
-- @bool[opt=true] __singleStateLoop If using a single state animation, should it loop?
--
-- @usage
--	-- Create a new NobleSprite, using a static image for its view.
--	mySprite = NobleSprite("path/to/image")
--
-- @usage
--	-- Create a new NobleSprite, using a Noble.Animation for its view.
--	mySprite = NobleSprite("path/to/spritesheet", true)
--
-- @usage
--	-- Extending NobleSprite.
--
--	-- MyCustomSprite.lua
--	MyCustomSprite = {}
--	class("MyCustomSprite").extends(NobleSprite)
--
--	function MyCustomSprite:init(__x, __y, __anotherFunArgument)
--		MyCustomSprite.super.init(self, "path/to/spritesheet", true)
--		-- Etc. etc.
--	end
--
--	-- MyNobleScene.lua
--	mySprite = MyCustomSprite(100, 100, "Fun!")
--
-- @see Noble.Animation:addState
--
function NobleSprite:init(__imageOrSpritesheet, __animated, __singleState, __singleStateLoop)
	NobleSprite.super.init(self)
	self.isNobleSprite = true -- This is important so other methods don't confuse this for a playdate.graphics.sprite. DO NOT modify this value at runtime.

	self.animated = __animated	-- NO NOT modify this value at runtime.

	if (__imageOrSpritesheet ~= nil) then
		if (__animated == true) then
			-- This sprite uses Noble.Animation for its "view."

			--- The animation for this NobleSprite.
			-- @see Noble.Animation.new
			self.animation = Noble.Animation.new(__imageOrSpritesheet)
		else
			-- This sprite uses playdate.graphics.image for its "view."
			self:setImage(Graphics.image.new(__imageOrSpritesheet))
		end
	end
end

function NobleSprite:draw()
	if (self.animation ~= nil) then
		self.animation:draw(0,0)
		self:markDirty()
	end
end

--- Use this to add this NobleSprite to your scene. This replaces `playdate.graphics.sprite:add()` to allow NobleSprites to be tracked by the current NobleScene.
--
-- To add a `playdate.graphics.sprite` to a scene, use `NobleScene:addSprite(__sprite)`.
-- @see NobleScene:addSprite
function NobleSprite:add()
	Noble.currentScene():addSprite(self)
end

function NobleSprite:superAdd()
	NobleSprite.super.add(self)
end

--- Use this to remove this NobleSprite from your scene. This replaces `playdate.graphics.sprite:remove()` to allow NobleSprites to be tracked by the current NobleScene.
--
-- To remove a `playdate.graphics.sprite` from a scene, use `NobleScene:removeSprite(__sprite)`.
-- @see NobleScene:removeSprite
function NobleSprite:remove()
	Noble.currentScene():removeSprite(self)
end

function NobleSprite:superRemove()
	NobleSprite.super.remove(self)
end