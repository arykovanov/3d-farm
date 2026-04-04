<?lsp
    local cookie = request:header("Cookie")
    local auth_token = cookie and cookie:match("auth_token=([^; \n]*)")
    if not auth_token then
        response:senderror(401, "Unauthorized")
        return
    end

    -- Return mock user for now, or decode JWT if we had the secret
    response:json({user={email="user@example.com"}})
?>
