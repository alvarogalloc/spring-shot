-- generate a 2d vector class
---@class vec
---@field x number
---@field y number
vec = {}
vec.__index = vec

function vec.new(x, y)
  local v = { x = x or 0, y = y or 0 }
  setmetatable(v, vec)
  return v
end

function vec:__add(other)
  return vec.new(self.x + other.x, self.y + other.y)
end

function vec:__sub(other)
  return vec.new(self.x - other.x, self.y - other.y)
end

function vec:__mul(other)
  if type(other) == "number" then
    return vec.new(self.x * other, self.y * other)
  else
    return vec.new(self.x * other.x, self.y * other.y)
  end
end

function vec:__div(other)
  if type(other) == "number" then
    return vec.new(self.x / other, self.y / other)
  else
    return vec.new(self.x / other.x, self.y / other.y)
  end
end

function vec:mod()
  return math.sqrt(self.x * self.x + self.y * self.y)
end

function vec:__eq(other)
  return self.x == other.x and self.y == other.y
end

function vec:__tostring()
  return "(" .. self.x .. ", " .. self.y .. ")"
end

return vec
