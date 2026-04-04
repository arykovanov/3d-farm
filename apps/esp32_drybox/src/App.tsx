import React, { useState, useEffect } from 'react';

function App() {
  const [temperature, setTemperature] = useState('');
  const [humidity, setHumidity] = useState('');
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState('');

  // Example to check auth on load
  useEffect(() => {
    // Basic auth check
    fetch('/api/user.lsp')
      .then(res => {
        if (res.status === 401 || res.status === 403 || res.redirected) {
          window.location.href = '/login/';
        }
      })
      .catch((err) => {
        console.error("Auth check failed:", err);
      });
  }, []);

  const handleSync = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setMessage('');

    try {
      // Dummy endpoint representing Sensor API sync
      const res = await fetch('/api/sensor_sync.lsp', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ temperature, humidity })
      });

      if (res.status === 401 || res.status === 403) {
         window.location.href = '/login/';
         return;
      }
      
      if (res.redirected) {
         window.location.href = '/login/';
         return;
      }

      if (res.ok) {
        setMessage('Data synced successfully.');
      } else {
        setMessage('Failed to sync. Unexpected error.');
      }
    } catch (err) {
      console.error(err);
      setMessage('Network error. Failed to sync.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <>
      <nav className="w-full bg-slate-950/60 backdrop-blur-xl border-b border-sky-300/10 shadow-[0_0_30px_rgba(125,211,252,0.05)] relative flex-none z-50">
        <div className="flex justify-between items-center h-16 px-8 w-full mx-auto max-w-7xl">
          <div className="text-2xl font-semibold tracking-tighter text-sky-300 font-inter">Glacier</div>
          <div className="hidden md:flex items-center space-x-8">
            <a className="text-slate-400 hover:text-sky-100 transition-colors font-inter tracking-tight" href="#">Dashboard</a>
            <a className="text-sky-300 border-b-2 border-sky-300 pb-1 font-inter tracking-tight" href="#">Sensors</a>
            <a className="text-slate-400 hover:text-sky-100 transition-colors font-inter tracking-tight" href="#">History</a>
            <a className="text-slate-400 hover:text-sky-100 transition-colors font-inter tracking-tight" href="#">Settings</a>
          </div>
          <div className="flex items-center space-x-4">
            <button className="p-2 text-slate-400 hover:bg-white/5 transition-all duration-300 rounded-full active:scale-95">
              <span className="material-symbols-outlined">notifications</span>
            </button>
            <button className="p-2 text-slate-400 hover:bg-white/5 transition-all duration-300 rounded-full active:scale-95">
              <span className="material-symbols-outlined">account_circle</span>
            </button>
          </div>
        </div>
      </nav>

      <main className="flex-grow flex items-center justify-center relative overflow-hidden py-12">
        <div className="absolute inset-0 z-0 pointer-events-none">
          <div className="absolute top-1/4 -left-24 w-96 h-96 bg-primary/10 rounded-full blur-[120px]"></div>
          <div className="absolute bottom-1/4 -right-24 w-96 h-96 bg-tertiary/10 rounded-full blur-[120px]"></div>
        </div>
        
        <div className="w-full max-w-md glass-panel p-10 rounded-xl relative z-10 shadow-[0_0_50px_rgba(125,211,252,0.03)] mx-4">
          <div className="mb-8 text-center">
            <h1 className="text-2xl font-semibold text-on-surface tracking-tight mb-2">Sensor Configuration</h1>
            <p className="text-on-surface-variant text-sm">Input the precise atmospheric values for calibration.</p>
          </div>
          
          <form className="space-y-6" onSubmit={handleSync}>
            <div className="space-y-2">
              <label className="block text-sm font-medium text-sky-300/80 tracking-wide" htmlFor="temperature">Temperature</label>
              <div className="relative group">
                <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none text-on-surface-variant group-focus-within:text-primary transition-colors">
                  <span className="material-symbols-outlined text-[20px]">thermostat</span>
                </div>
                <input 
                  className="block w-full pl-11 pr-4 py-3.5 bg-surface-container-low/40 border border-white/10 rounded-lg text-on-surface placeholder:text-slate-600 focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary/40 transition-all backdrop-blur-sm" 
                  id="temperature" 
                  placeholder="e.g. 24°C" 
                  type="text"
                  value={temperature}
                  onChange={(e) => setTemperature(e.target.value)}
                />
              </div>
            </div>
            
            <div className="space-y-2">
              <label className="block text-sm font-medium text-sky-300/80 tracking-wide" htmlFor="humidity">Humidity</label>
              <div className="relative group">
                <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none text-on-surface-variant group-focus-within:text-primary transition-colors">
                  <span className="material-symbols-outlined text-[20px]">humidity_percentage</span>
                </div>
                <input 
                  className="block w-full pl-11 pr-4 py-3.5 bg-surface-container-low/40 border border-white/10 rounded-lg text-on-surface placeholder:text-slate-600 focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary/40 transition-all backdrop-blur-sm" 
                  id="humidity" 
                  placeholder="e.g. 45%" 
                  type="text"
                  value={humidity}
                  onChange={(e) => setHumidity(e.target.value)}
                />
              </div>
            </div>
            
            <div className="pt-4">
              <button 
                className="w-full bg-primary/10 hover:bg-primary/20 border border-primary/30 text-primary font-medium py-3.5 rounded-lg transition-all duration-300 active:scale-95 shadow-[0_0_20px_rgba(125,211,252,0.1)] disabled:opacity-50" 
                type="submit"
                disabled={loading}
              >
                {loading ? "Syncing..." : "Sync Data"}
              </button>
            </div>

            {message && (
              <div className="text-center mt-4 text-sm text-sky-300/80">
                {message}
              </div>
            )}
          </form>
          
          <div className="mt-8 flex justify-center space-x-6 grayscale opacity-40">
            <img alt="Certification badge" className="h-6" src="https://lh3.googleusercontent.com/aida-public/AB6AXuAPqGhWDr7No6XYOafpD93nyJCiK9ITuQf0a0TsXnaELUwqUvRp20Km_pAoeas_3Mp3KecSCvA-0hmUnu2FLv1pwJQYzSr4ftXoYSiLiWzNPmyjgEzxqhuVmuD1-K0B_HmQ2jSHPw-PHGuQmiJvi-kdDkFfBDBXMhFINiAe7KOR7OhE8eseWVa9-mUjIWupkjHoRCtHUXLQMLQfpjUilhCugRc5xOFcf9SagUd00iRuAEuPcXV5Ax_ySYamt_LpTeqyQf6gNN8kV20"/>
            <img alt="Technology badge" className="h-6" src="https://lh3.googleusercontent.com/aida-public/AB6AXuBHseoJAs-TK7a27AnhOSs9SW-TrU6MsDSLnU2wvqPvRigyyOrCkibVTlC6Ubvxy9aCoYXMblRVGw3qO9EhEXnCEpU9ewW35OuS5br4_RNpGUjoVS2FHmlv0iqrP-ovSRUrgPeJWW7r69THfvE664kp9giaHrcjE_1DBI3w5joBOtW9HN0_hRIJK1yAZSg8M6st3mfxhtLQOttp66rRjcCZtzJJ8QTje6GQxaLpMjResbAZl05M4CNjupFtUWiQvjJhzSBvSwqNgoc"/>
          </div>
        </div>
      </main>
      
      <footer className="w-full border-t border-sky-300/5 bg-slate-950/40 backdrop-blur-md flex-none z-50">
        <div className="flex flex-col md:flex-row justify-between items-center py-6 px-8 max-w-7xl mx-auto w-full">
          <div className="flex items-center space-x-4 mb-4 md:mb-0">
            <span className="text-lg font-bold text-sky-300 font-inter">Glacier</span>
            <span className="text-sm font-inter text-slate-500">© 2024 Glacier Systems. All rights reserved.</span>
          </div>
          <div className="flex space-x-8">
            <a className="text-sm font-inter text-slate-500 hover:text-sky-200 transition-colors cursor-pointer" href="#">Privacy Policy</a>
            <a className="text-sm font-inter text-slate-500 hover:text-sky-200 transition-colors cursor-pointer" href="#">Terms of Service</a>
            <a className="text-sm font-inter text-slate-500 hover:text-sky-200 transition-colors cursor-pointer" href="#">API Documentation</a>
          </div>
        </div>
      </footer>
    </>
  );
}

export default App;
