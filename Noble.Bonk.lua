--- Engine-specific error handling.
-- Noble Engine overrides/supercedes some Playdate SDK behavior. A "bonk" is what happens when your game breaks the engine.
--
-- Some bonks will throw during normal operation, but others ("debug bonks") introduce some execution overhead so are not
-- checked by default.
--
-- @module Noble.Bonk
--
Noble.Bonk = {}

local bonksAreSetup = false
local checkingForBonks = false

local debugBonks = {}

function Noble.Bonk.setupDebugBonks()
	if (bonksAreSetup) then
		error ("BONK-BONK: You can only run this once, by running Noble.new() with __setupBonks as true.")
	end
	debugBonks.crankDocked = playdate.crankDocked
	debugBonks.crankUndocked = playdate.crankUndocked
	debugBonks.update = playdate.update
	debugBonks.pause = playdate.gameWillPause
	debugBonks.resume = playdate.gameWillResume
	bonksAreSetup = true
end

--- Begin checking for debug bonks on every frame. This also resets values to check agaisnt, so you may wish to run it even if it's already running.
function Noble.Bonk.startCheckingDebugBonks()
	if (bonksAreSetup) then
		checkingForBonks = true
	else
		error("BONK-BONK: You need to run Noble.new() with __setupBonks as true to use this.")
	end
end

--- Stop checking for debug bonks on every frame.
function Noble.Bonk.stopCheckingDebugBonks()
	debugBonks = {}
	checkingForBonks = false
	bonksAreSetup = false
end

--- Are we checking for debug bonks?
-- @treturn bool
function Noble.Bonk.checkingDebugBonks()
	return checkingForBonks
end

--- Manually check for debug bonks.
-- This method runs every frame when `checkingDebugBonks()` is true, but you may call it manually
function Noble.Bonk.checkDebugBonks()

	if (playdate.crankDocked ~= debugBonks.crankDocked) then
		error("BONK: Don't manaully define playdate.crankDocked(). Create a crankDocked() inside of an inputHandler instead.")
	end
	if (playdate.crankUndocked ~= debugBonks.crankUndocked) then
		error("BONK: Don't manaully define playdate.crankUndocked(). Create a crankUndocked() inside of an inputHandler instead.")
	end
	if (playdate.update ~= debugBonks.update) then
		error("BONK: Don't manaully define playdate.update(). Put update code in your scenes' update() methods instead.")
	end
	if (playdate.gameWillPause ~= debugBonks.pause) then
		error("BONK: Don't manaully define playdate.gameWillPause(). Put pause code in your scenes' pause() methods instead.")
	end
	if (playdate.gameWillResume ~= debugBonks.resume) then
		error("BONK: Don't manaully define playdate.gameWillResume(). Put resume code in your scenes' resume() methods instead.")
	end

	if (Graphics.sprite.getAlwaysRedraw() == false) then
		error("BONK: Don't use Graphics.sprite.setAlwaysRedraw(false) unless you know what you're doing...")
	end
	if (Noble.Input.currentHandler == nil) then
		error("BONK: Don't set Noble.Input.currentHandler to nil directly. To disable input, use Noble.Input.setHandler() (without an arguement) instead.")
	end
	if (Noble.currentScene.baseColor == Graphics.kColorClear) then
		error("BONK: Don't set a scene's baseColor to Graphics.kColorClear, silly.")
	end

end