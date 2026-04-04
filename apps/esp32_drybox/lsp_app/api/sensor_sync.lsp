<?lsp
    local cookie = request:header("Cookie")
    local auth_token = cookie and cookie:match("auth_token=([^; \n]*)")
    if not auth_token then
        response:senderror(401, "Unauthorized")
        return
    end
    
    if request:method() == "POST" then
        local data = request:data()
        -- Simulator state sync
        response:json({status="success", message="Synced"})
    else
        response:senderror(405, "Method Not Allowed")
    end
?>
