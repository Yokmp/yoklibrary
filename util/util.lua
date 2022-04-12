
---Returns table ``t`` with keys for name and amount
---@param t table|string ``lua {string, number?}``
---@return table ``{ name = "name": string, amount = n: integer }``
function ylib.util.add_pairs(t)

  if type(t) == "table" and t[1] then --they can be empty and would be "valid" until ...
---@diagnostic disable-next-line: undefined-field
    if t.name then return t end       --ignore if it has pairs already
    if type(t[1]) ~= "string" then error(" First value must be 'string'") end
    if type(t[2]) ~= "number" then t[2] = 1 end -- this is risky
    return { name = t[1], amount = t[2] or 1}
  elseif type(t) == "string" then
    log(" Warning: add_pairs("..type(t[1])..", "..type(t[2])..") - implicitly set value - amount = 1")
    return { name = t, amount = 1}
  end

  return t
end

---Returns _true_ if table contains anything
---@return boolean
function ylib.util.check_table(table)
  if not table then return false end
  if not type(table) == "table" then return false end
  if not next(table) then return false end
  return true
end


---Returns mixed rgb values, big thx to Honktown
---@param t1 color|table
---@param t2 color|table
---@return color|table
function ylib.util.mix_tints(t1, t2)
	local tint1 = {t1.r or t1[1] or 0, t1.g or t1[2] or 0, t1.b or t1[3] or 0, t1.a or t1[4]}
	local tint2 = {t2.r or t2[1] or 0, t2.g or t2[2] or 0, t2.b or t2[3] or 0, t2.a or t2[4]}
  local divisor = 1.9

	for _, tint in pairs({tint1, tint2}) do
		if tint[1] > 1 or tint[2] > 1 or tint[3] > 1 or (tint[4] and tint[4] > 1) then
			for i, c in pairs(tint) do
				tint[i] = c/255
			end
		end
		tint[4] = tint[4] or 1
	end

	return {r = (tint1[1]+tint2[1])/divisor, g = (tint1[2]+tint2[2])/divisor, b = (tint1[3]+tint2[3])/divisor, a = 1}--(tint1[4]+tint2[4])/divisor}
end


---Returns all matching entries of two tables and returns a list
---@param ta table list
---@param tb table list
---@return table matches list
function ylib.util.get_table_matches(ta, tb)
  local matches = {}
  for _, va in ipairs(ta) do
    for _, vb in ipairs(tb) do
      if va == vb then
        matches[#matches+1] = va
      end
    end
  end
  return matches
end


function ylib.util.assembler1pipepictures(color)
  local tint = {}
  if ylib.util.check_table(color) then
    tint = {
      r = color.r or 1,
      g = color.g or 1,
      b = color.b or 1,
      a = color.a or 1
    }
  else
    tint = {r = 1, g = 1, b = 1, a = 1}
  end
  return {
    north = {
      filename = "__ylib__/graphics/assembling-machine-1/hr-assembling-machine-1-pipe-N.png",
      priority = "extra-high",
      width = 71,
      height = 38,
      shift = util.by_pixel(2.25, 13.5),
      scale = 0.5,
      tint = tint
    },
    east = {
      filename = "__ylib__/graphics/assembling-machine-1/hr-assembling-machine-1-pipe-E.png",
      priority = "extra-high",
      width = 42,
      height = 76,
      shift = util.by_pixel(-24.5, 1),
      scale = 0.5,
      tint = tint
    },
    south = {
      filename = "__ylib__/graphics/assembling-machine-1/hr-assembling-machine-1-pipe-S.png",
      priority = "extra-high",
      width = 88,
      height = 61,
      shift = util.by_pixel(0, -31.25),
      scale = 0.5,
      tint = tint
    },
    west = {
      filename = "__ylib__/graphics/assembling-machine-1/hr-assembling-machine-1-pipe-W.png",
      priority = "extra-high",
      width = 39,
      height = 73,
      shift = util.by_pixel(25.75, 1.25),
      scale = 0.5,
      tint = tint
    }
  }
end

