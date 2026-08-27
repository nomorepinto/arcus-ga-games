import Link from 'next/link';
import { Gamepad2, Trophy, Activity, ArrowRight, ShieldAlert } from 'lucide-react';
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from '@/components/ui/card';

export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center p-6 text-zinc-50">
      
      {/* Main Portal Card with Squid Game Vibe */}
      <Card className="w-full max-w-md border-rose-500/30 shadow-[0_0_30px_rgba(225,29,72,0.15)] bg-zinc-950/90 backdrop-blur-md">
        <CardHeader className="text-center pb-2">
          
          {/* Neon Pink/Teal Icon Badge */}
          <div className="mx-auto mb-4 flex h-14 w-14 items-center justify-center rounded-2xl bg-rose-600/10 border border-rose-500/40 shadow-[0_0_15px_rgba(225,29,72,0.3)]">
            <Gamepad2 className="w-7 h-7 text-rose-500" />
          </div>

          <CardTitle className="text-3xl font-extrabold tracking-wider text-white uppercase font-mono">
            GA Minigames
          </CardTitle>
          
          <CardDescription className="text-zinc-400 font-medium">
            Select your trial. Survival is not guaranteed.
          </CardDescription>
        </CardHeader>
        
        <CardContent className="grid gap-3.5 mt-4">
          
          {/* Sipa Game Link */}
          <Link 
            href="/sipa" 
            className="group flex items-center justify-between p-4 rounded-xl border border-zinc-800 bg-zinc-900/60 hover:bg-rose-950/30 hover:border-rose-500/50 transition-all duration-300 shadow-sm"
          >
            <div className="flex items-center gap-3.5">
              <div className="p-2 rounded-lg bg-teal-500/10 border border-teal-500/20 text-teal-400 group-hover:shadow-[0_0_10px_rgba(45,212,191,0.3)] transition-all">
                <Activity className="w-5 h-5" />
              </div>
              <div>
                <div className="font-semibold text-white tracking-wide">Play Sipa</div>
                <div className="text-xs text-teal-400 font-mono tracking-wider">Trial 01: Multi-ball Chaos</div>
              </div>
            </div>
            <ArrowRight className="w-4 h-4 text-zinc-500 group-hover:text-rose-400 group-hover:translate-x-1 transition-all" />
          </Link>

          {/* Leaderboard Link */}
          <Link 
            href="/leaderboard" 
            className="group flex items-center justify-between p-4 rounded-xl border border-zinc-800 bg-zinc-900/60 hover:bg-rose-950/30 hover:border-rose-500/50 transition-all duration-300 shadow-sm"
          >
            <div className="flex items-center gap-3.5">
              <div className="p-2 rounded-lg bg-yellow-500/10 border border-yellow-500/20 text-yellow-400 group-hover:shadow-[0_0_10px_rgba(234,179,8,0.3)] transition-all">
                <Trophy className="w-5 h-5" />
              </div>
              <div>
                <div className="font-semibold text-white tracking-wide">Global Leaderboards</div>
                <div className="text-xs text-teal-400 font-mono tracking-wider">View Participant Standings</div>
              </div>
            </div>
            <ArrowRight className="w-4 h-4 text-zinc-500 group-hover:text-rose-400 group-hover:translate-x-1 transition-all" />
          </Link>

        </CardContent>
      </Card>
      
      {/* Decorative Footer Note */}
      <div className="mt-8 flex items-center gap-2 text-xs font-mono text-teal-300 tracking-widest uppercase">
        <ShieldAlert className="w-4 h-4 text-teal-300 animate-pulse" />
        Authorized Personnel Only
      </div>

    </main>
  );
}