local ua = require("opcua.api")
local uaServer = ua.newServer()

uaServer:initialize()

uaServer:run()
return uaServer
