-- require('__debugadapter__/debugadapter.lua')

logging = settings.startup["ymm-logging"].value
require("util.logger")

---create the categories for molten metals
categories = {smelting="ymm_smelting", casting="ymm_casting"}
data:extend({
  { type = "recipe-category", name = categories.smelting, },
  { type = "recipe-category", name = categories.casting },
})

ylib = {}


require("util.logger")
require("util.icons")
require("util.util")
require("util.functions")
require("util.fluids")
require("util.technology")
require("recipe.recipe")
require("recipe.exotic")

