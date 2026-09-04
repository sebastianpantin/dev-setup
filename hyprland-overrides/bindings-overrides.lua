-- Custom bindings for Hyprland (Omarchy quattro / Lua config)
--
-- Loaded from ~/.config/hypr/bindings.lua via dofile(), which runs after
-- Omarchy's defaults, so hl.unbind() here can take over default keys.

-- Unbind the Omarchy defaults we take over.
hl.unbind("SUPER + J") -- was: Toggle window split
hl.unbind("SUPER + K") -- was: Keybindings menu
hl.unbind("SUPER + L") -- was: Toggle workspace layout
hl.unbind("SUPER + CTRL + K") -- was: Herdr keybindings

-- Drop arrow-key focus so hjkl is the only way to move focus.
hl.unbind("SUPER + LEFT")
hl.unbind("SUPER + RIGHT")
hl.unbind("SUPER + UP")
hl.unbind("SUPER + DOWN")

-- Move focus with SUPER + hjkl
o.bind("SUPER + H", "Focus on left window", hl.dsp.focus({ direction = "l" }))
o.bind("SUPER + L", "Focus on right window", hl.dsp.focus({ direction = "r" }))
o.bind("SUPER + K", "Focus on above window", hl.dsp.focus({ direction = "u" }))
o.bind("SUPER + J", "Focus on below window", hl.dsp.focus({ direction = "d" }))

-- Cycle workspaces
o.bind("SUPER + CTRL + J", "Next workspace", hl.dsp.focus({ workspace = "e+1" }))
o.bind("SUPER + CTRL + K", "Prev workspace", hl.dsp.focus({ workspace = "e-1" }))

-- Carry the active window along
o.bind("SUPER + SHIFT + J", "Move to next workspace", hl.dsp.window.move({ workspace = "e+1" }))
o.bind("SUPER + SHIFT + K", "Move to prev workspace", hl.dsp.window.move({ workspace = "e-1" }))

-- Bar toggle (quattro replaced waybar with the Omarchy shell).
-- Also on the default SUPER + SHIFT + SPACE.
o.bind_toggle("SUPER + B", "Toggle top bar", "bar")

-- Resize windows submap
o.bind("SUPER + R", "Resize mode", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
  hl.bind("l", hl.dsp.window.resize({ x = 10, y = 0, relative = true }), { repeating = true })
  hl.bind("h", hl.dsp.window.resize({ x = -10, y = 0, relative = true }), { repeating = true })
  hl.bind("k", hl.dsp.window.resize({ x = 0, y = -10, relative = true }), { repeating = true })
  hl.bind("j", hl.dsp.window.resize({ x = 0, y = 10, relative = true }), { repeating = true })
  hl.bind("escape", hl.dsp.submap("reset"))
end)

-- Omarchy's keybindings cheatsheet, displaced from SUPER + K by the focus binds above.
o.bind("SUPER + I", "Keybindings", "omarchy-menu-keybindings")
