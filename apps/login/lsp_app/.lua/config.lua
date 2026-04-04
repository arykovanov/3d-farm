
-- OAuth Configuration for Login Application

local conf = require("loadconf")

local google_config_url
local ms_config_url
if conf.oauth_portal then
   google_config_url = conf.oauth_portal
   ms_config_url = conf.oauth_portal
else
   google_config_url = "https://accounts.google.com/.well-known/openid-configuration"
   ms_config_url = string.format("https://login.microsoftonline.com/%s/v2.0/.well-known/openid-configuration", conf.microsoft.tenant)
end

local function getOauthConfig(url)
   local res, err = ba.http.get(url)
   if not res then
      trace("Failed to get OAuth config from " .. url .. ": " .. tostring(err))
      return nil
   end
   local body = res:read("*a")
   local config = ba.json.decode(body)
   if not config then
      trace("Failed to decode OAuth config from " .. url)
      return nil
   end

   if not config.authorization_endpoint or not config.token_endpoint then
      trace("OAuth config from " .. url .. " is missing authorization_endpoint or token_endpoint")
      error("Invalid oauth config from " .. url)
   end

   return {
      auth_url = config.authorization_endpoint,
      token_url = config.token_endpoint,
      user_info_url = config.userinfo_endpoint or "", -- UserInfo might not be present in some configs
   }
end

local google_config = getOauthConfig(google_config_url)
local ms_config = getOauthConfig(ms_config_url)

local config = {
   -- Google OAuth
   google = {
      client_id = conf.google.client_id,
      client_secret = conf.google.client_secret,
      auth_url = google_config.auth_url,
      token_url = google_config.token_url,
      user_info_url = google_config.user_info_url,
      scope = "openid email profile"
   },
   -- Microsoft Entra ID (Azure AD)
   microsoft = {
      client_id = conf.microsoft.client_id,
      client_secret = conf.microsoft.client_secret,
      tenant_id = conf.microsoft.tenant,
      auth_url = ms_config.auth_url,
      token_url = ms_config.token_url,
      user_info_url = ms_config.user_info_url,
      scope = "openid email profile"
   },

   -- Internal settings
   jwt_secret = ba.rndbs(32),
   token_expiry = 3600 * 24, -- 24 hours
   cookie_name = "auth_token"
}

return config
