import { Routes, Route } from 'react-router-dom'
import { HomePage } from './pages/HomePage'

function App() {
  return (
    <div className="min-h-screen bg-gray-50">
      <main>
        <Routes>
          <Route path="/" element={<HomePage />} />
          <Route path="*" element={<div>Page not found</div>} />
        </Routes>
      </main>
    </div>
  )
}

export default App