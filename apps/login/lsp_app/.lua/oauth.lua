-- OAuth Helper for Login Application
local http = require("http")
local config = require("config")

local function getAuthUrl(provider, state, redirectUri)
   local p = config[provider]
   if not p then return nil, "Unknown provider" end
   
   local url = p.auth_url .. "?" ..
      "client_id=" .. ba.urlencode(p.client_id) ..
      "&response_type=code" ..
      "&redirect_uri=" .. ba.urlencode(redirectUri) ..
      "&scope=" .. ba.urlencode(p.scope) ..
      "&state=" .. ba.urlencode(state)
   
   return url
end

local function exchangeCode(provider, code, redirectUri)
   local p = config[provider]
   if not p then return nil, "Unknown provider" end
   
   local h = http.create()
   local options = {
      url = p.token_url,
      method = "POST",
      body = "client_id=" .. ba.urlencode(p.client_id) ..
             "&client_secret=" .. ba.urlencode(p.client_secret) ..
             "&code=" .. ba.urlencode(code) ..
             "&redirect_uri=" .. ba.urlencode(redirectUri) ..
             "&grant_type=authorization_code",
      header = {
         ["Content-Type"] = "application/x-www-form-urlencoded"
      }
   }
   
   local ok, err = h:request(options)
   if not ok then return nil, "HTTP request failed: " .. tostring(err) end
   
   local s = h:status()
   local data = h:read("*a")
   h:close()
   
   if s ~= 200 then
      return nil, "Token Exchange failed: Status " .. s .. ", " .. tostring(data)
   end
   
   local tokenData = ba.json.decode(data)
   return tokenData
end

local function getUserInfo(provider, accessToken)
   local p = config[provider]
   if not p then return nil, "Unknown provider" end
   
   local h = http.create()
   local options = {
      url = p.user_info_url,
      header = {
         ["Authorization"] = "Bearer " .. accessToken
      }
   }
   
   local ok, err = h:request(options)
   if not ok then return nil, "HTTP request failed: " .. tostring(err) end
   
   local s = h:status()
   local data = h:read("*a")
   h:close()
   
   if s ~= 200 then
      return nil, "Get User Info failed: Status " .. s .. ", " .. tostring(data)
   end
   
   local userData = ba.json.decode(data)
   return userData
end

return {
   getAuthUrl = getAuthUrl,
   exchangeCode = exchangeCode,
   getUserInfo = getUserInfo
}
