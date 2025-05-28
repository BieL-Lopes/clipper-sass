import React, { useState } from "react";
import axios from "axios";

function App() {
  const [file, setFile] = useState(null);
  const [clipUrl, setClipUrl] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const handleUpload = async () => {
    if (!file) return;

    setLoading(true);
    setError("");
    setClipUrl("");

    const formData = new FormData();
    formData.append("file", file);

    try {
      const res = await axios.post("http://localhost:8010/upload", formData);
      if (res.data.clip) {
        setClipUrl(`http://localhost:8010/clip/${res.data.clip}`);
      } else {
        setError("Nenhum trecho detectado.");
      }
    } catch (err) {
      setError("Erro ao enviar o vídeo.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="p-6 max-w-xl mx-auto text-center">
      <h1 className="text-2xl font-bold mb-4">Gerador de Clipe Automático</h1>
      <input type="file" accept="video/mp4" onChange={(e) => setFile(e.target.files[0])} className="mb-4" />
      <button onClick={handleUpload} disabled={loading || !file} className="bg-blue-600 text-white px-4 py-2 rounded">
        {loading ? "Enviando..." : "Enviar vídeo"}
      </button>
      {error && <p className="text-red-500 mt-4">{error}</p>}
      {clipUrl && (
        <div className="mt-6">
          <h2 className="text-lg font-semibold mb-2">Clipe gerado:</h2>
          <video src={clipUrl} controls width="480" />
        </div>
      )}
    </div>
  );
}

export default App;
