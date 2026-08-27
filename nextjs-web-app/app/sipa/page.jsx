import Link from 'next/link';
import { ArrowLeft, Gamepad2 } from 'lucide-react';
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from '@/components/ui/card';

export default function SipaPage() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center bg-zinc-50 dark:bg-zinc-950 p-6 text-zinc-900 dark:text-zinc-50">
      
      {/* Container wrapper matching portal width */}
      <div className="w-full max-w-xl space-y-4">
        
        {/* Navigation & Header */}
        <div className="flex items-center justify-between">
          <Link 
            href="/" 
            className="inline-flex items-center gap-2 text-sm font-medium text-zinc-500 transition-colors hover:text-zinc-900 dark:text-zinc-400 dark:hover:text-zinc-50"
          >
            <ArrowLeft className="h-4 w-4" />
            Back to Portal
          </Link>
          
          <Link 
            href="/leaderboard" 
            className="text-sm font-medium text-blue-600 dark:text-blue-400 hover:underline"
          >
            View Leaderboard &rarr;
          </Link>
        </div>

        {/* Coss UI Game Container Card */}
        <Card className="border-zinc-200 shadow-sm dark:border-zinc-800 bg-white dark:bg-zinc-950">
          <CardHeader className="text-center pb-3">
            <CardTitle className="text-2xl font-semibold tracking-tight">Sipa Minigame</CardTitle>
            <CardDescription className="text-zinc-500 dark:text-zinc-400">
              Keep the sipa in the air and watch out for multi-ball chaos!
            </CardDescription>
          </CardHeader>
          
          <CardContent className="flex flex-col items-center p-6 pt-0">
            {/* Resizable Phone Screen Aesthetic Wrapper */}
            <div 
              className="w-[480px] h-[720px] min-w-[300px] min-h-[400px] max-w-full max-h-[80vh] rounded-xl border border-zinc-200 dark:border-zinc-800 bg-zinc-950 shadow-inner overflow-hidden relative p-1"
            >
              <iframe 
                src="/godot/sipa_export.html" 
                className="w-full h-full border-none outline-none block pointer-events-auto rounded-lg"
                title="Sipa Minigame"
              />
            </div>
            
            <p className="text-xs text-zinc-400 dark:text-zinc-500 mt-3 text-center">
              Tip: Click and drag the bottom-right corner of the box to resize it freely.
            </p>
          </CardContent>
        </Card>

      </div>
    </main>
  );
}