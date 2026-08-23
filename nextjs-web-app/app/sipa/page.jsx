export default function SipaPage() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center bg-zinc-950 p-6">
      <div className="mb-4 text-center">
        <h1 className="text-3xl font-extrabold text-white tracking-tight">Sipa Minigame</h1>
        <p className="text-sm text-zinc-400 mt-1">Keep the sipa in the air and watch out for multi-ball chaos!</p>
      </div>

      {/* Resizable container wrapper */}
      <div 
        className="w-[480px] h-[750px] min-w-[300px] min-h-[400px] max-w-[90vw] max-h-[90vh] rounded-2xl border-4 border-zinc-700 bg-black shadow-2xl overflow-auto relative p-1"
        style={{ resize: 'both' }}
      >
        <iframe 
          src="/godot/sipa_export.html" 
          className="w-full h-full border-none outline-none block pointer-events-auto"
          title="Sipa Minigame"
        />
      </div>
      <p className="text-xs text-zinc-500 mt-2">Tip: Click and drag the bottom-right corner of the box to resize it freely.</p>
    </main>
  );
}