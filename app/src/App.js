import logo from './logo.svg';
import './App.css';

function App() {
  // Environment variables from secrets
  const username = process.env.REACT_APP_USERNAME || 'Not Set';
  const password = process.env.REACT_APP_PASSWORD || 'Not Set';
  
  // ConfigMap values
  const apiUrl = process.env.REACT_APP_API_URL || 'http://default-api-url';
  const environment = process.env.REACT_APP_ENVIRONMENT || 'development';

  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <h2>Environment Variables (Secrets)</h2>
        <p>Username: {username}</p>
        <p>Password: {password}</p>
        
        <h2>ConfigMap Values</h2>
        <p>API URL: {apiUrl}</p>
        <p>Environment: {environment}</p>
      </header>
    </div>
  );
}

export default App;
