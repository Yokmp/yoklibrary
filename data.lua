ylib = ylib or {}
ylib.recipe = ylib.recipe or {}
ylib.fluid = ylib.fluid or {}
ylib.util = ylib.util or {}
ylib.icon = ylib.icon or {}
ylib.technology = ylib.technology or {}

loglevel = settings.startup["ylib-logging"].value
require("util.logger")


require("util.util")
require("util.functions")
require("util.fluids")
require("util.technology")
require("recipe.recipe")
require("recipe.exotic")
require("util.icons")


-- if require("_testing") then log("TESTING") end