-- Authentication module for Login Application
local jwt = require(".lua/jwt")
local config = require("config")

local function signToken(payload)
   return jwt.sign(payload, config.jwt_secret, {alg = "HS256"})
end

local function verifyToken(token)
   return jwt.verify(token, config.jwt_secret)
end

local function getUserFromRequest(request)
   local cookie = request:header("Cookie")
   if not cookie then return nil end
   
   local token = cookie:match(config.cookie_name .. "=([^; \n]*)")
   if not token then return nil end
   
   local ok, payload = verifyToken(token)
   if ok then return payload end
   
   return nil
end

return {
   signToken = signToken,
   verifyToken = verifyToken,
   getUserFromRequest = getUserFromRequest
}
