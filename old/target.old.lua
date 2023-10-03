local vec = require("vec")

---@class target
---@field pos vec
---@field radius number
target = {}

---comment
---@param pos vec
---@param radius number
---@return target
function target.new(pos, radius)
	return setmetatable({
		pos = pos,
    radius = radius,
	}, { __index = target })
end


---@param projectile_pos vec
function target:hit_by(projectile_pos, obstacle_pos)
  
end

function target:draw()
  love.graphics.circle("fill", self.pos.x, self.pos.y, self.radius)
end

return target
