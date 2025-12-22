--- A li'l game engine for Playdate.
-- @module Noble

--
-- https://noblerobot.com/
--

-- Playdate libraries
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/animation"
import "CoreLibs/animator"
import "CoreLibs/object"
import "CoreLibs/ui"
import "CoreLibs/math"
import "CoreLibs/timer"
import "CoreLibs/frameTimer"
import "CoreLibs/crank"

-- We create aliases for both fun and performance reasons.
Graphics = playdate.graphics
Display = playdate.display
Geometry = playdate.geometry
Ease = playdate.easingFunctions
UI = playdate.ui
File = playdate.file
Datastore = playdate.datastore
Timer = playdate.timer
FrameTimer = playdate.frameTimer

-- In lua, variables are global by default, but having a "Global" object to put
-- variables into is useful for maintaining sanity if you're coming from an OOP language.
-- It's included here for basically no reason at all. Noble Engine doesn't use it. (◔◡◔)
Global = {}

-- It all fits inside this table, oooo!
Noble = {}

-- Third-party libraries
import 'libraries/noble/libraries/Signal'
import 'libraries/noble/libraries/Sequence'

-- Noble libraries, modules, and classes.
import 'libraries/noble/utilities/Utilities.lua'
import 'libraries/noble/utilities/Ease.lua' -- Extensions to the Ease library
import 'libraries/noble/modules/Noble.Animation.lua'
import 'libraries/noble/modules/Noble.Bonk.lua'
import 'libraries/noble/modules/Noble.GameData.lua'
import 'libraries/noble/modules/Noble.Input.lua'
import 'libraries/noble/modules/Noble.Settings.lua'
import 'libraries/noble/modules/Noble.Transition.lua'
import 'libraries/noble/modules/Noble.Text.lua'
import 'libraries/noble/modules/Noble.Menu.lua'
import 'libraries/noble/modules/NobleScene.lua'
import 'libraries/noble/modules/NobleSprite.lua'

local isTransitioning = false
local currentScene = nil
local engineInitialized = false

-- configuration
--

local defaultConfiguration = {
	defaultTransition = Noble.Transition.DipToBlack,
	defaultTransitionDuration = 1.5,
	defaultTransitionHoldTime = 0.25,
	transitionDurationIncludesHoldTime = true,
	enableDebugBonkChecking = false,
	alwaysRedraw = true,
}
local configuration = Utilities.copy(defaultConfiguration)

--- Engine initialization. Run this once in your main.lua file to begin your game.
-- @tparam NobleScene StartingScene This is the scene your game begins with, such as a title screen, loading screen, splash screen, etc. **NOTE: Pass the scene's class name, not an instance of the scene.**
-- @number[opt=1.5] __launcherTransitionDuration If you want to transition from the final frame of your launch image sequence, enter a duration in seconds here.
-- @tparam[opt=Noble.Transition.DipToBlack] Noble.Transition __launcherTransition If a transition duration is set, use this transition type.
-- @tparam[opt={}] table __launcherTransitionProperties Provide a table of properties to apply to the launcher transition. See the documentation for the transition you're using for a list of available properties.
-- @tparam[opt={}] table __configuration Provide a table of Noble Engine configuration values. This will run `Noble.setConfig` for you at launch.
-- @tparam[opt={}] table __sceneProperties A table consisting of user-defined properties which are passed into and handled by the new scene's init() method.
-- @usage
-- Noble.new(
-- 	TitleScreen,
-- 	2,
-- 	Noble.Transition.DipToWhite,
-- 	{
-- 		holdTime = 0,
-- 		ease = Ease.outInQuad
-- 	},
-- 	{
-- 		defaultTransition = Noble.Transition.Imagetable,
-- 		defaultTransitionDuration = 1.75,
-- 		enableDebugBonkChecking = true,
-- 	}
-- )
-- @see NobleScene
-- @see Noble.transition
-- @see setConfig
-- @see NobleScene.init
function Noble.new(StartingScene, __launcherTransitionDuration, __launcherTransition, __launcherTransitionProperties, __configuration, __sceneProperties)

	math.randomseed(playdate.getSecondsSinceEpoch()) -- Set a new random seed at runtime.

	if (engineInitialized) then
		error("BONK: You can only run Noble.new() once.")
		return
	end

	-- If the user supplies a config object, we use it, otherwise, we set default values.
	if (__configuration ~= nil) then
		Noble.setConfig(__configuration)
	else
		Noble.resetConfig()
	end

	-- Screen drawing: see the Playdate SDK for details on these methods.
	Graphics.sprite.setBackgroundDrawingCallback(
		function (x, y, width, height)
			if (currentScene ~= nil) then
				-- Each scene has its own method for this. We only want to run one at a time.
				currentScene:drawBackground(x, y, width, height)
			else
				Graphics.clear(Graphics.kColorBlack)
			end
		end
	)
	-- Override this Playdate method that we've used already and don't want to be used again!
	Graphics.sprite.setBackgroundDrawingCallback = function(callback)
		error("BONK: Don't call Graphics.sprite.setBackgroundDrawingCallback() directly. Put background drawing code in your scenes' drawBackground() methods instead.")
	end

	-- These values are used if not set.
	local launcherTransition =			__launcherTransition or defaultConfiguration.defaultTransition
	local launcherTransitionDuration =	__launcherTransitionDuration or 1.5
	local launcherTransitionProperties =__launcherTransitionProperties or {}

	-- Now that everything is set, let's-a go!
	engineInitialized = true
	Noble.transition(StartingScene, launcherTransitionDuration, launcherTransition, launcherTransitionProperties, __sceneProperties)
end

--- This checks to see if `Noble.new` has been run. It is used internally to ward off bonks.
-- @treturn bool
-- @see Noble.Bonk
function Noble.engineInitialized()
	return engineInitialized
end

--- Miscellaneous Noble Engine configuration options / default values.
-- This table cannot be edited directly. Use `Noble.getConfig` and `Noble.setConfig`.
-- @table configuration
-- @tparam[opt=Noble.Transition.DipToBlack] Noble.Transition defaultTransition When running `Noble.transition` if the transition is unspecified, it will use this one.
-- @number[opt=1.5] defaultTransitionDuration When running `Noble.transition` if the scene transition duration is unspecified, it will take this long in seconds.
-- @bool[opt=false] enableDebugBonkChecking Noble Engine-specific errors are called "Bonks." You can set this to true during development in order to check for more of them. However, it uses resources, so you will probably want to turn it off before release.
-- @bool[opt=true] alwaysRedraw This sets the Playdate SDK method `playdate.graphics.sprite.setAlwaysRedraw`. See the Playdate SDK for details on how this function works, and the reasons you might want to set it as true or false for your project.
-- @see Noble.getConfig
-- @see Noble.setConfig
-- @see Noble.Bonk.startCheckingDebugBonks

--- Retrieve miscellaneous Noble Engine configuration options / default values
-- @return A table of all configuration values
-- @see configuration
-- @see setConfig
function Noble.getConfig()
	return configuration
end

--- Optionally customize miscellaneous Noble Engine configuration options / default values. You may run this method to change these values during runtime.
-- @tparam table __configuration This is a table with your configuration values in it.
-- @see configuration
-- @see getConfig
function Noble.setConfig(__configuration)

	if (__configuration == nil) then
		error("BONK: You cannot pass a nil value to Noble.setConfig(). If you want to reset to default values, use Noble.resetConfig().")
	end

	if (__configuration.defaultTransition ~= nil)			then configuration.defaultTransition = __configuration.defaultTransition end
	if (__configuration.defaultTransitionDuration ~= nil)	then configuration.defaultTransitionDuration = __configuration.defaultTransitionDuration end
	if (__configuration.defaultTransitionHoldTime ~= nil)	then configuration.defaultTransitionHoldTime = __configuration.defaultTransitionHoldTime end
	if (__transitionDurationIncludesHoldTime ~= nil)		then configuration.transitionDurationIncludesHoldTime = __configuration.transitionDurationIncludesHoldTime end

	if (__configuration.enableDebugBonkChecking ~= nil)	then
		configuration.enableDebugBonkChecking = __configuration.enableDebugBonkChecking
		if (configuration.enableDebugBonkChecking == true) then Noble.Bonk.enableDebugBonkChecking() end
	end

	if (__configuration.alwaysRedraw ~= nil) then
		configuration.alwaysRedraw = __configuration.alwaysRedraw
		Graphics.sprite.setAlwaysRedraw(configuration.alwaysRedraw)
	end

end

--- Reset miscellaneous Noble Engine configuration values to their defaults.
-- @see getConfig
-- @see setConfig
function Noble.resetConfig()
	Noble.setConfig(Utilities.copy(defaultConfiguration))
end

-- Transition stuff
--
local currentTransition = nil
local queuedScene = nil

--- Transition to a new scene (at the end of this frame).
--- This method will create a new scene, mark the previous one for garbage collection, and animate between them.
--- Additional calls to this method within the same frame (before the already-called transition begins), will override previous calls. Any calls to this method once a transition begins will be ignored until the transition completes.
-- @tparam NobleScene NewScene The scene to transition to. Pass the scene's class, not an instance of the scene. You always transition from `Noble.currentScene`
-- @number[opt=1.5] __duration The length of the transition, in seconds.
-- @tparam[opt=Noble.TransitionType.DIP_TO_BLACK] Noble.Transition __transition If a transition duration is set, use this transition type. If not set, it will use the value of `configuration.defaultTransition`.
-- @tparam[opt={}] table __transitionProperties A table consisting of properties for this transition. Properties not set here will use values that transition's `defaultProperties` table.
-- @tparam[opt={}] table __sceneProperties A table consisting of user-defined properties which are passed into and handled by the new scene's init() method.
-- @usage
-- Noble.transition(Level2, 1, Noble.Transition.CrossDissolve,
-- 	{
-- 		dither = Graphics.image.kDitherTypeDiagonalLine
-- 		ease = Ease.outQuint
-- 	}
-- )
-- --
-- Noble.transition(Level2, 1, Noble.Transition.DipToBlack,
-- 	{
-- 		holdTime = 0.5,
-- 		ease = Ease.outInElastic
-- 	}
-- )
-- --
-- Noble.transition(Level, 1, Noble.Transition.SlideOff,
-- 	{
-- 		x = 400,
-- 		y = 150
-- 		rotation = 45
-- 	},
-- 	{
-- 		levelName = "Level Two: The Second Level!"
-- 		levelData = "levels/level2.json",
-- 	}
-- )
-- @see Noble.isTransitioning
-- @see NobleScene
-- @see Noble.Transition
function Noble.transition(NewScene, __duration, __transition, __transitionProperties, __sceneProperties)
	if (isTransitioning) then
		-- This bonk no longer throws an error (compared to previous versions of Noble Engine), but maybe it still should?
		warn("BONK: You can't start a transition in the middle of another transition, silly!")
		return -- Let's get otta here!
	elseif (queuedScene ~= nil) then
		-- Calling this method multiple times between Noble.update() calls is probably not intentional behavior.
		warn("Soft-BONK: You are calling Noble.transition() multiple times within the same frame. Did you mean to do that?")
		-- We don't return here because maybe the developer *did* intend to override a previous call to Noble.transition().
	end

	local sceneProperties = __sceneProperties or {}
	queuedScene = NewScene(sceneProperties) -- Creates new scene object. Its init() function runs now.

	currentTransition = (__transition or configuration.defaultTransition)(
		__duration or configuration.defaultTransitionDuration,
		__transitionProperties or {}
	)
end


-- These methods are triggered during an transition

function Noble.transitionStartHandler()
	isTransitioning = true
	if (currentScene ~= nil) then
		currentScene:exit()				-- The current scene runs its "goodbye" code. Sprites are taken out of the simulation.
	end
	Noble.Input.setHandler(nil)			-- Disable user input.
end

function Noble.transitionMidpointHandler()
	if (currentScene ~= nil) then
		currentScene:finish()
		currentScene = nil				-- Allows current scene to be garbage collected.
	end
	currentScene = queuedScene			-- New scene's update loop begins.
	queuedScene = nil
	currentScene:enter()				-- The new scene runs its "hello" code.
end

function Noble.transitionCompleteHandler()
	isTransitioning = false				-- Reset
	currentTransition = nil				-- Clear the transition variable.
	currentScene:start()				-- The new scene is now active.
end

--- Get the current scene object
-- @treturn NobleScene
function Noble.currentScene()
	return currentScene
end

--- Get the name of the current scene
-- @treturn string
function Noble.currentSceneName()
	return currentScene.name
end

--- Check to see if the game is transitioning between scenes.
-- Useful to control game logic that lives outside of a scene's `update()` method.
-- @treturn bool
function Noble.isTransitioning()
	return isTransitioning
end

--- Show/hide the Playdate SDK's FPS counter.
-- @field bool
Noble.showFPS = false;

local crankIndicatorActive = false
local crankIndicatorForced = false

local transitionCanvas = Graphics.image.new(400, 240)

-- Game loop
--
function playdate.update()
	Noble.Input.update()				-- Check for Noble Engine-specific input methods.

	Sequence.update()					-- Update all animations that use the Sequence library.

	-- Here we check to see if a transition currently in progress needs screenshots of the new scene.
	-- If so, we route drawing for this frame into a new context.
	if (isTransitioning and currentTransition._captureScreenshotsDuringTransition) then
		currentTransition.newSceneScreenshot = Graphics.image.new(400, 240)
		Graphics.pushContext(currentTransition.newSceneScreenshot)
	end

	if (currentScene ~= nil) then
		currentScene:update()			-- Scene-specific update code.
	end

	Graphics.sprite.update()			-- Let's draw our sprites (and backgrounds).

	if (isTransitioning) then
		if (currentTransition._captureScreenshotsDuringTransition) then
			Graphics.popContext()
		end
		transitionCanvas:clear(Graphics.kColorClear)

		Graphics.pushContext(transitionCanvas)
		currentTransition:draw()
		Graphics.popContext()

		Graphics.setImageDrawMode(currentTransition.drawMode)
		transitionCanvas:drawIgnoringOffset(0, 0)
		Graphics.setImageDrawMode(Graphics.kDrawModeCopy)
	end

	-- We want to draw the crank indicator and FPS display last
	crankIndicatorActive, crankIndicatorForced = Noble.Input.getCrankIndicatorStatus()
	if (crankIndicatorActive) then
		if (playdate.isCrankDocked() or crankIndicatorForced) then
			UI.crankIndicator:update()	-- Draw crank indicator (if requested).
		end
	end
	if (Noble.showFPS) then
		playdate.drawFPS(4, 4)
	end

	Timer.updateTimers()		-- Finally, update all SDK timers.
	FrameTimer.updateTimers() 	-- Update all frame timers

	if (Noble.Bonk.checkingDebugBonks()) then	-- Checks for code that breaks the engine.
		Noble.Bonk.checkDebugBonks()
	end

	-- Once this frame is complete, we can check to see if it's time to start transitioning to a new scene.
	if (not isTransitioning and currentTransition ~= nil) then
		currentTransition:execute()
	end
end

function playdate.gameWillPause()
	if (currentScene ~= nil) then
		currentScene:pause()
	end
end

function playdate.gameWillResume()
	if (currentScene ~= nil) then
		currentScene:resume()
	end
end
