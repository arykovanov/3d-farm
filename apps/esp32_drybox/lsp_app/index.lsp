<?lsp
-- Main Application Entry Point with Auth Check
local auth_token = request:header("Cookie"):match("auth_token=([^; \n]*)")
if not auth_token then
    response:sendredirect("/login/")
    return
end

if io.exists("index.html") then
   include"index.html"
else
   response:senderror(404, "Frontend build (index.html) not found. Run 'npm run build' first.")
end
?>
