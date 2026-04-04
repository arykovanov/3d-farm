import fs from 'fs';

const authSnippet = `<?lsp
    local cookie = request:header("Cookie")
    local auth_token = cookie and cookie:match("auth_token=([^; \\n]*)")
    if not auth_token then
        response:sendredirect("/login/")
        return
    end
?>
`;

const html = fs.readFileSync('dist/index.html', 'utf8');
fs.writeFileSync('dist/index.lsp', authSnippet + html);
fs.unlinkSync('dist/index.html');
console.log('Successfully secured index.lsp');
