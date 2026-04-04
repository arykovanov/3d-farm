<?lsp
-- OAuth2 Callback Handler for Login Application
local auth = require(".lua/auth")
local oauth = require(".lua/oauth")
local config = require("config")

local code = request:query("code")
local state = request:query("state")
local provider = request:query("provider") or "google" -- default to google, but better to detect from state

-- Decode the state for return URL
local stateData = ba.json.decode(ba.b64urldecode(state))
local returnUrl = stateData.redirect or "/"

if not code then
   response:senderror(400, "OAuth code missing")
   return
end

-- 1. Exchange code for token
local redirectUri = "https://" .. request:header("Host") .. "/login/lsp_app/callback.lsp"
local tokenData, err = oauth.exchangeCode(provider, code, redirectUri)

if not tokenData then
   response:senderror(401, "Token exchange failed: " .. tostring(err))
   return
end

-- 2. Get user info
local userInfo, err = oauth.getUserInfo(provider, tokenData.access_token)

if not userInfo then
   response:senderror(401, "User info retrieval failed: " .. tostring(err))
   return
end

-- 3. Issue JWT token
local jwtToken, err = auth.signToken({
   id = userInfo.sub or userInfo.id,
   email = userInfo.email,
   name = userInfo.name,
   iat = os.time(),
   exp = os.time() + config.token_expiry
})

if not jwtToken then
   response:senderror(500, "JWT generation failed: " .. tostring(err))
   return
end

-- 4. Set cookie and redirect back to initial page
response:header("Set-Cookie", config.cookie_name .. "=" .. jwtToken .. "; Path=/; HttpOnly; SameSite=Strict")
response:sendredirect(returnUrl)
?>
Redirecting to <a href="<?lsp=returnUrl?>"><?lsp=returnUrl?></a>...
