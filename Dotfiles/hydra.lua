-- autostart hydra
autolaunch.set(true)

-- notify on start
notify.show("Hydra", "Started!", "", "")

-- window functions
local margin = 10

-- push to screen edge
function push(win, direction)
	local screen = win:screen():frame_without_dock_or_menu()
	local frames = {
		[ "up" ] = function()
			return {
				x = margin + screen.x,
				y = margin + screen.y,
				w = screen.w - margin * 2,
				h = screen.h / 2 - margin
			}
		end,

		[ "down" ] = function()
			return {
				x = margin + screen.x,
				y = margin * 3 / 4 + screen.h / 2 + screen.y,
				w = screen.w - margin * 2,
				h = screen.h / 2 - margin * (2 - 1 / 4)
			}
		end,

		[ "left" ] = function()
			return {
				x = margin + screen.x,
				y = margin + screen.y,
				w = screen.w / 2 - margin * (2 - 1 / 4),
				h = screen.h - margin * (2 - 1 / 4)
			}
		end,

		[ "right" ] = function()
			return {
				x = margin / 2 + screen.w / 2 + screen.x,
				y = margin + screen.y,
				w = screen.w / 2 - margin * (2 - 1 / 4),
				h = screen.h - margin * (2 - 1 / 4)
			}
		end
	}

	win:setframe(frames[direction]())
end

-- move by "margin"
function nudge(win, direction)
	local screen = win:screen():frame_without_dock_or_menu()
	local frame = win:frame()

	if (direction == "up") then
		frame.y = math.max(screen.y + margin, frame.y - margin);
	end

	if (direction == "down") then
		frame.y = math.min(screen.y + screen.h - margin * 1 / 4, frame.y + margin);
	end

	if (direction == "left") then
		frame.x = math.max(screen.x + margin, frame.x - margin);
	end

	if (direction == "right") then
		frame.x = math.min(screen.x + screen.w - margin - frame.w, frame.x + margin);
	end

	win:setframe(frame)
end

-- fit inside screen
function fitframe(screen, frame)
	frame.w = math.min(frame.w, screen.w - margin * 2)
	frame.h = math.min(frame.h, screen.h - margin * (2 - 1 / 4))

	return frame
end

-- center inside screen
function centerframe(screen, frame)
	frame.x = screen.w / 2 - frame.w / 2 + screen.x
	frame.y = screen.h / 2 - frame.h / 2 + screen.y

	return frame
end

-- center given window
function centerwindow(win)
	local screen = win:screen():frame_without_dock_or_menu()
	local frame = win:frame()

	win:setframe(centerframe(screen, frame))
end

-- fullscreen window with margin
function fullscreen(win)
	local screen = win:screen():frame_without_dock_or_menu()
	local frame = {
		x = margin + screen.x,
		y = margin + screen.y,
		w = screen.w - margin * 2,
		h = screen.h - margin * (2 - 1 / 4)
	}

	win:setframe(frame)
end

-- throw to next screen, center and fit
function nextscreen(win)
	local screen = win:screen():next():frame_without_dock_or_menu()
	local frame = win:frame()

	frame.x = screen.x
	frame.y = screen.y

	win:setframe(centerframe(screen, fitframe(screen, frame)))
	win:focus()
end

-- set window size and center
function centerwithsize(win, w, h)
	local screen = win:screen():frame_without_dock_or_menu()
	local frame = win:frame()

	frame.w = w;
	frame.h = h;

	win:setframe(centerframe(screen, fitframe(screen, frame)))
end

-- save and restore window positions
local positions = {}

function winposition(win, option)
	local id = win:application():bundleid()
	local frame = win:frame()

	if option == "save" then
		notify.show("Hydra", "position for " .. id .. " saved", "", "")
		positions[id] = frame
	end

	if option == "load" and positions[id] then
		notify.show("Hydra", "position for " .. id .. " restored", "", "")
		win:setframe(positions[id])
	end
end

-- keyboard modifier for bindings
local mod1 = { "cmd", "ctrl" }
local mod2 = { "cmd", "ctrl", "alt" }

-- window mod1ifiers
hotkey.bind(mod1, "c", function() centerwindow(window.focusedwindow()) end)
hotkey.bind(mod1, "z", function() fullscreen(window.focusedwindow()) end)
hotkey.bind(mod1, "tab", function() nextscreen(window.focusedwindow()) end)

-- push to edges and nudge
fnutils.each({ "up", "down", "left", "right" }, function(direction)
	hotkey.bind(mod1, direction, function()
		push(window:focusedwindow(), direction)
	end)

	hotkey.bind(mod2, direction, function()
		nudge(window:focusedwindow(), direction)
	end)
end)

-- set window sizes
fnutils.each({
	{ key = 1, w = 1400, h = 940 },
	{ key = 2, w = 980, h = 920 },
	{ key = 3, w = 800, h = 880 },
	{ key = 4, w = 800, h = 740 },
	{ key = 5, w = 760, h = 620 },
	{ key = 6, w = 770, h = 470 }
}, function(object)
	hotkey.bind(mod1, object.key, function()
		centerwithsize(window.focusedwindow(), object.w, object.h)
	end)
end)

-- save and restore window positions
hotkey.bind(mod1, "s", function() winposition(window.focusedwindow(), "save") end)
hotkey.bind(mod1, "r", function() winposition(window.focusedwindow(), "load") end)

-- reload hydra settings
hotkey.bind(mod1, "h", function() hydra:reload() end)

-- launch and focus applications
fnutils.each({
	{ key = "t", app = "Terminal" },
	{ key = "s", app = "Safari" },
	{ key = "f", app = "Finder" },
	{ key = "n", app = "Notational Velocity" },
	{ key = "p", app = "TaskPaper" },
	{ key = "m", app = "MacVim" }
}, function(object)
	hotkey.bind(mod2, object.key, function()
		application.launchorfocus(object.app)
	end)
end)