import Link from 'next/link';
import { ArrowLeft } from 'lucide-react';
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from '@/components/ui/card';

export default function DalgonaPage() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center p-6 text-zinc-50">
      
      {/* Container wrapper matching portal width */}
      <div className="w-full max-w-xl space-y-4">
        
        {/* Navigation & Header */}
        <div className="flex items-center justify-between">
          <Link 
            href="/" 
            className="inline-flex items-center gap-2 text-sm font-medium text-zinc-400 transition-colors hover:text-rose-400 font-mono tracking-wider"
          >
            <ArrowLeft className="h-4 w-4" />
            Back to Portal
          </Link>
          
          <Link 
            href="/leaderboard" 
            className="text-sm font-medium text-teal-400 hover:text-teal-300 hover:underline font-mono tracking-wider"
          >
            View Leaderboard &rarr;
          </Link>
        </div>

        {/* Coss UI Game Container Card */}
        <Card className="border-rose-500/30 shadow-[0_0_30px_rgba(225,29,72,0.15)] bg-zinc-950/90 backdrop-blur-md">
          <CardHeader className="text-center pb-3 border-b border-rose-500/20 mb-4">
            <CardTitle className="text-2xl font-extrabold tracking-wider text-white uppercase font-mono">
              Trial 02: Dalgona
            </CardTitle>
            <CardDescription className="text-teal-400 font-mono text-xs">
              Trace the honeycomb stencil without cracking the cookie!
            </CardDescription>
          </CardHeader>
          
          <CardContent className="flex flex-col items-center p-6 pt-0">
            {/* Resizable Phone Screen Aesthetic Wrapper */}
            <div 
              className="w-[480px] h-[720px] min-w-[300px] min-h-[400px] max-w-full max-h-[80vh] rounded-xl border border-rose-500/30 bg-zinc-950 shadow-[0_0_15px_rgba(0,0,0,0.8)] overflow-hidden relative p-1"
              style={{ resize: 'both' }}
            >
              <iframe 
                src="/godot/dalgona_export.html" 
                className="w-full h-full border-none outline-none block pointer-events-auto rounded-lg"
                title="Dalgona Minigame"
              />
            </div>
            
            <p className="text-xs text-zinc-500 font-mono mt-4 text-center tracking-wide">
              Tip: Click and drag the bottom-right corner of the box to resize it freely.
            </p>
          </CardContent>
        </Card>

      </div>
    </main>
  );
}