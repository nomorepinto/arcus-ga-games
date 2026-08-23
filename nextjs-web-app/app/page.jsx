import Link from 'next/link';

export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center bg-zinc-950 text-white p-6">
      <h1 className="text-4xl font-extrabold mb-4">GA Minigames Portal</h1>
      <p className="text-zinc-400 mb-8">Select a game to play:</p>
      
      <div className="flex gap-4">
        <Link href="/sipa" className="px-6 py-3 bg-blue-600 hover:bg-blue-700 rounded-lg font-semibold transition-colors">
          Play Sipa
        </Link>
      </div>
    </main>
  );
}