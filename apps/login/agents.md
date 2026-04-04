# Implementation Plan for Login Application

## Objective

Implement an LSP application for OAuth login (Microsoft, Google, Internal) with a React/TypeScript frontend and a JWT-issuing backend.

## Architecture
- **Backend (LSP)**: Uses Real Time Logic (BAS) API.
  - `index.lsp`: Handles session check and redirects.
  - `oauth_callback.lsp`: Handles OAuth code exchange and JWT issuance.
  - `.lua/auth.lua`: Logic for user authentication and session management.
  - `.lua/oauth.lua`: Helper module for OAuth provider interactions.
- **Frontend (React/TS)**:
  - Glacier (Glassmorphism) design system from Stitch.
  - Screens for selecting login provider and internal login form.

## Tasks

1. **Frontend Setup**:
  - Initialize Vite project with React and TypeScript in `server/login`.
  - Apply Stitch design (Glacier theme).
  - Implement components (Login buttons, Glassmorphism cards).
2. **Backend implementation**:
  - Implement OAuth flow for Microsoft Entra ID and Google.
  - Implement Internal user authentication (placeholder for database).
  - Implement JWT token generation using `jwt.lua`.
  - Handle session and redirect logic.
3. **Integration**:
  - Configure OAuth credentials.
  - Set up build script for React and serving it from LSP.
4. **Final Polish**:
  - Smooth transitions and animations (Glacier theme).
  - Error handling.

# Testing.

## Use mock_sso

1. open /login/ page it asks to enter username/password..
2. it redirects to /sso page where you can enter username/password and get JWT token.
