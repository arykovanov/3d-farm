-- OAuth Configuration for Login Application

local config = {
   -- Google OAuth
   google = {
      client_id = "YOUR_GOOGLE_CLIENT_ID",
      client_secret = "YOUR_GOOGLE_CLIENT_SECRET",
      auth_url = "https://accounts.google.com/o/oauth2/v2/auth",
      token_url = "https://oauth2.googleapis.com/token",
      user_info_url = "https://www.googleapis.com/oauth2/v3/userinfo",
      scope = "openid email profile"
   },
   -- Microsoft Entra ID (Azure AD)
   microsoft = {
      client_id = "YOUR_MICROSOFT_CLIENT_ID",
      client_secret = "YOUR_MICROSOFT_CLIENT_SECRET",
      auth_url = "https://login.microsoftonline.com/common/oauth2/v2.0/authorize",
      token_url = "https://login.microsoftonline.com/common/oauth2/v2.0/token",
      user_info_url = "https://graph.microsoft.com/oidc/userinfo",
      scope = "openid email profile"
   },
   -- Internal settings
   jwt_secret = "YOUR_JWT_SECRET_KEY",
   token_expiry = 3600 * 24, -- 24 hours
   cookie_name = "auth_token"
}

return config
