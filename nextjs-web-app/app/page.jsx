import Link from 'next/link';
import { Gamepad2, Trophy, Activity, ArrowRight } from 'lucide-react';
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from '@/components/ui/card';

export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center bg-zinc-50 dark:bg-zinc-950 p-6 text-zinc-900 dark:text-zinc-50">
      <Card className="w-full max-w-md border-zinc-200 dark:border-zinc-800 shadow-sm bg-white dark:bg-zinc-950">
        <CardHeader className="text-center pb-2">
          <div className="mx-auto mb-4 flex h-12 w-12 items-center justify-center rounded-full bg-zinc-100 dark:bg-zinc-900">
            <Gamepad2 className="w-6 h-6 text-zinc-900 dark:text-zinc-100" />
          </div>
          <CardTitle className="text-2xl font-semibold tracking-tight">GA Minigames</CardTitle>
          <CardDescription className="text-zinc-500 dark:text-zinc-400">
            Select a game to play or check your global standings.
          </CardDescription>
        </CardHeader>
        
        <CardContent className="grid gap-3 mt-4">
          {/* Sipa Game Link */}
          <Link 
            href="/sipa" 
            className="group flex items-center justify-between p-4 rounded-lg border border-zinc-200 dark:border-zinc-800 bg-zinc-50 dark:bg-zinc-900/50 hover:bg-zinc-100 dark:hover:bg-zinc-900 transition-colors"
          >
            <div className="flex items-center gap-3">
              <Activity className="w-5 h-5 text-blue-500" />
              <div className="font-medium">Play Sipa</div>
            </div>
            <ArrowRight className="w-4 h-4 text-zinc-400 group-hover:text-zinc-900 dark:group-hover:text-zinc-100 transition-colors" />
          </Link>

          {/* Leaderboard Link */}
          <Link 
            href="/leaderboard" 
            className="group flex items-center justify-between p-4 rounded-lg border border-zinc-200 dark:border-zinc-800 bg-zinc-50 dark:bg-zinc-900/50 hover:bg-zinc-100 dark:hover:bg-zinc-900 transition-colors"
          >
            <div className="flex items-center gap-3">
              <Trophy className="w-5 h-5 text-yellow-500" />
              <div className="font-medium">Global Leaderboards</div>
            </div>
            <ArrowRight className="w-4 h-4 text-zinc-400 group-hover:text-zinc-900 dark:group-hover:text-zinc-100 transition-colors" />
          </Link>
        </CardContent>
      </Card>
    </main>
  );
}