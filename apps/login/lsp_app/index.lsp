<?lsp
-- Login Application Entry Point
local auth = require(".lua/auth")
local oauth = require(".lua/oauth")
local config = require("config")

-- 1. Check if we already have a session
local user = auth.getUserFromRequest(request)
local redirectUrl = request:header("Referer") or "/" -- Where we came from

if user then
   -- Already logged in, redirect back
   response:sendredirect(redirectUrl)
   return
end

-- 2. Handle provider redirects or API calls if needed.
-- In a React frontend, we might want to handle provider selections there.
-- When a user clicks a "Google Login" button, they'll go to index.lsp?provider=google
local provider = request:query("provider")

if provider then
   -- Step 1: Initiate OAuth flow
   local redirectUri = "https://" .. request:header("Host") .. "/login/lsp_app/callback.lsp"
   local state = ba.b64urlencode(ba.json.encode({redirect = redirectUrl}))
   local url, err = oauth.getAuthUrl(provider, state, redirectUri)
   
   if url then
      response:sendredirect(url)
      return
   else
      response:senderror(400, "Error: " .. tostring(err))
      return
   end
end

-- 3. Serve the React Frontend (React app files)
-- For now, if the build doesn't exist, we'll return a simple React entry point.
-- Use the standard static file serving logic in LSP if needed.
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Login - DryBox</title>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
  <!-- We'll link the React scripts here after we build them -->
</head>
<body>
  <div id="root"></div>
  <script type="module" src="/login/src/main.tsx"></script>
</body>
</html>
