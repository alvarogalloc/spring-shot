local vec = require("vec")

---@class target
---@field pos vec
---@field radius number
local target = {}

function target.new(pos, radius)
	return setmetatable({
		pos = pos,
    radius = radius,
	}, { __index = target })
end


---@param projectile_pos vec
function target:hit_by(projectile_pos, obstacle_pos)
  
end
