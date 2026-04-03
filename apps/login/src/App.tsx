import React, { useState } from 'react';
import './index.css';

const App: React.FC = () => {
  const [useInternal, setUseInternal] = useState(false);
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');

  const handleOAuth = (provider: string) => {
    // Redirect through the LSP app entry point
    window.location.href = `/login/lsp_app/index.lsp?provider=${provider}`;
  };

  const handleInternalLogin = (e: React.FormEvent) => {
    e.preventDefault();
    // In a real application, we'd POST to a login API in LSP
    console.log('Internal Login:', { username, password });
    window.alert('Internal login placeholder triggered.');
  };

  return (
    <div className="glass-card">
      <h1>Welcome Back</h1>
      <p>Please select a login method to continue</p>
      
      {!useInternal ? (
        <div className="provider-list">
          <button 
            className="auth-button primary" 
            onClick={() => handleOAuth('microsoft')}
          >
            <img src="https://authjs.dev/img/providers/azure-ad-dark.svg" alt="Microsoft" width="20" height="20" />
            Continue with Microsoft
          </button>
          
          <button 
            className="auth-button" 
            onClick={() => handleOAuth('google')}
          >
            <img src="https://authjs.dev/img/providers/google.svg" alt="Google" width="20" height="20" />
            Continue with Google
          </button>

          <div className="divider">
            <span>or use internal account</span>
          </div>

          <button 
            className="auth-button" 
            onClick={() => setUseInternal(true)}
          >
            Internal Login
          </button>
        </div>
      ) : (
        <form onSubmit={handleInternalLogin}>
          <input 
            type="text" 
            placeholder="Username" 
            required 
            value={username}
            onChange={(e) => setUsername(e.target.value)}
          />
          <input 
            type="password" 
            placeholder="Password" 
            required 
            value={password}
            onChange={(e) => setPassword(e.target.value)}
          />
          <button type="submit">Sign In</button>
          
          <button 
            className="auth-button" 
            style={{ marginTop: '16px', color: 'var(--on-surface-variant)', fontSize: '0.875rem' }}
            onClick={() => setUseInternal(false)}
          >
            Back to Providers
          </button>
        </form>
      )}
    </div>
  );
};

export default App;
