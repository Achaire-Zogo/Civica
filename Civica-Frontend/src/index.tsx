import React from 'react';
import { createRoot } from 'react-dom/client';
import App from './App';

// Ensure the root element exists
const container = document.getElementById('root');
if (!container) {
  throw new Error('Root element not found');
}

// Create root and render the app
const root = createRoot(container);
root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
