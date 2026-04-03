-- Auth Check Helper for other LSP pages
local auth = require("login/lsp_app/.lua/auth")

return function(request, response)
   local user = auth.getUserFromRequest(request)
   if not user then
      -- Redirect to login app
      local currentUrl = request:url()
      response:header("Location", "/login/lsp_app/index.lsp")
      response:status(302)
      return nil
   end
   return user
end
