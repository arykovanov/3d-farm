<?lsp
response:setcontenttype("text/html")
local function esc(value)
  local text = tostring(value or "")
  text = text:gsub("&", "&amp;")
  text = text:gsub("<", "&lt;")
  text = text:gsub(">", "&gt;")
  text = text:gsub('"', "&quot;")
  text = text:gsub("'", "&#39;")
  return text
end
local function field(name, default)
  local value = request:data(name)
  if value == nil or value == "" then
    return default or ""
  end
  return tostring(value)
end

local conf=require"loadconf"
local openid = conf.mock_sso
local host = request:header("host") or fmt("localhost:%d", mako.port)
local conf=require"loadconf"

local openid = conf.mock_sso
local conf=require"loadconf"

local openid = conf.mock_sso
local authorizeUrl = string.format("http://%s/sso/%s/oauth2/v2.0/authorize", host, openid.tenant)
trace(authorizeUrl)

local clientId = field("client_id")
local redirectUri = field("redirect_uri")
local responseType = field("response_type", "code")
local responseMode = field("response_mode", "form_post")
local scope = field("scope", "openid profile")
local state = field("state")
local nonce = field("nonce")
?>
<!doctype html>
<html>
  <head>
    <meta charset="utf-8">
    <title>Mock Microsoft Login</title>
    <style>
      html, body {
        height: 100%;
        margin: 0;
        padding: 0;
      }
      body {
        min-height: 100vh;
        min-width: 100vw;
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        background: #f7f7f7;
      }
      .center-container {
        display: flex;
        flex-direction: column;
        align-items: center;
        background: #fff;
        padding: 2rem 2.5rem 2.5rem 2.5rem;
        border-radius: 10px;
        box-shadow: 0 8px 22px rgba(0,0,0,0.07), 0 1.5px 5px rgba(0,0,0,0.10);
      }
      form {
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 1rem;
        min-width: 250px;
      }
      fieldset {
        margin-top: 0.8em;
        margin-bottom: 0.8em;
        border-radius: 7px;
        padding: 0.5em 1em 0.7em 1em;
      }
      input[type="text"], input[type="password"] {
        padding: .4em;
        margin-top: .2em;
        border-radius: 5px;
        border: 1px solid #bbb;
        min-width: 170px;
      }
      input[type="checkbox"] {
        margin-right: 6px;
        margin-left: 0.5em;
      }
      button[type="submit"] {
        margin-top: 1rem;
        padding: 0.5em 1.6em;
        background: #0067c5;
        color: #fff;
        border: none;
        border-radius: 5px;
        font-size: 1em;
        cursor: pointer;
      }
      h1 {
        margin-bottom: 1.3em;
      }
      label {
        display: flex;
        flex-direction: column;
        align-items: flex-start;
      }
      @media (max-width: 440px) {
        .center-container { padding: 1rem; min-width: 0; }
        form { min-width: 0; width: 100%; }
      }
    </style>
  </head>
  <body>
    <div class="center-container">
      <h1>Mock Microsoft Login</h1>
      <form method="post" action="<?lsp=esc(authorizeUrl)?>">
        <label>
          Username
          <input type="text" name="username" required autofocus>
        </label>
        <label>
          Password
          <input type="password" name="password" required>
        </label>
        <fieldset>
          <legend>Permissions:</legend>
          <div>
            <input type="checkbox" id="read" name="read" checked />
            <label for="read" style="display:inline">Read</label>
          </div>
          <div>
            <input type="checkbox" id="write" name="write" checked/>
            <label for="write" style="display:inline">Write</label>
          </div>
        </fieldset>
        <input type="hidden" name="client_id" value="<?lsp=esc(clientId)?>">
        <input type="hidden" name="redirect_uri" value="<?lsp=esc(redirectUri)?>">
        <input type="hidden" name="response_type" value="<?lsp=esc(responseType)?>">
        <input type="hidden" name="response_mode" value="<?lsp=esc(responseMode)?>">
        <input type="hidden" name="scope" value="<?lsp=esc(scope)?>">
        <?lsp if state ~= "" then ?>
        <input type="hidden" name="state" value="<?lsp=esc(state)?>">
        <?lsp end ?>
        <?lsp if nonce ~= "" then ?>
        <input type="hidden" name="nonce" value="<?lsp=esc(nonce)?>">
        <?lsp end ?>
        <button type="submit">Sign in</button>
      </form>
    </div>
  </body>
</html>
