data:extend({
  {
      type = "string-setting",
      name = "ymm-logging",
      setting_type = "startup",
      default_value = "none",
      allowed_values = {"warning", "all", "none"},
      order = "aa"
  },
})


-- local _settings
-- for name, value in pairs(settings.startup) do
--     if string.find(tostring(name), "ymm-", 0, true) then
--         -- name = string.match(name, "^%w+%-%w+%-(%w+)")
--         local _t = {}
--         for word in string.gmatch(name, "[^-]+") do
--             table.insert(_t, tonumber(word) or word)
--         end
--         name = _t[4] and _t[3].."-".._t[4] or _t[3]
--         _settings[tostring(name)] = value.value
--     end
-- end
-- log(serpent.block(_settings))
-- error()