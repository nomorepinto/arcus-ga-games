'use client';

import Link from 'next/link';
import { useEffect, useState } from 'react';
import { Trophy, Medal, Clock, Activity, ArrowLeft } from 'lucide-react';

// Using coss.ui / shadcn UI primitives
import { Card, CardHeader, CardTitle, CardContent, CardDescription } from '@/components/ui/card';
import { Tabs, TabsList, TabsTrigger, TabsContent } from '@/components/ui/tabs';
import { Table, TableHeader, TableRow, TableHead, TableBody, TableCell } from '@/components/ui/table';
import { Badge } from '@/components/ui/badge';

export default function Leaderboard() {
  const [sipaScores, setSipaScores] = useState([]);
  const [dalgonaScores, setDalgonaScores] = useState([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    async function fetchLeaderboards() {
      try {
        // Fetch Sipa scores
        const sipaRes = await fetch('/api/leaderboard?game=SIPA', { cache: 'no-store' });
        const sipaData = await sipaRes.json();
        setSipaScores(sipaData.data || []);

        // Fetch Dalgona scores
        const dalgonaRes = await fetch('/api/leaderboard?game=DALGONA', { cache: 'no-store' });
        const dalgonaData = await dalgonaRes.json();
        setDalgonaScores(dalgonaData.data || []);

      } catch (error) {
        console.error("Failed to fetch scores", error);
      } finally {
        setIsLoading(false);
      }
    }

    fetchLeaderboards();
  }, []);

  const renderTable = (scores, gameType) => {
    const isDalgona = gameType === 'DALGONA';

    return (
      <div className="rounded-xl border border-rose-500/20 overflow-hidden bg-zinc-950/60 backdrop-blur-sm">
        <Table>
          <TableHeader className="bg-zinc-900/80 border-b border-rose-500/20">
            <TableRow className="hover:bg-transparent">
              <TableHead className="w-16 text-center text-zinc-400 font-mono uppercase tracking-wider">Rank</TableHead>
              <TableHead className="text-zinc-400 font-mono uppercase tracking-wider">Participant</TableHead>
              {isDalgona && (
                <TableHead className="text-center text-zinc-400 font-mono uppercase tracking-wider">Difficulty</TableHead>
              )}
              <TableHead className="text-right text-zinc-400 font-mono uppercase tracking-wider">
                {isDalgona ? 'Time (s)' : 'Kicks'}
              </TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {scores.length === 0 ? (
              <TableRow className="hover:bg-transparent">
                <TableCell colSpan={isDalgona ? 4 : 3} className="h-32 text-center text-zinc-500 font-mono">
                  {isLoading ? 'Decrypting participant data...' : 'No survival records found.'}
                </TableCell>
              </TableRow>
            ) : (
              scores.map((player, index) => (
                <TableRow key={player.PlayerId || index} className="border-b border-zinc-900/50 hover:bg-rose-950/25 transition-colors">
                  <TableCell className="text-center font-mono font-bold">
                    {index === 0 ? <Trophy className="w-4 h-4 mx-auto text-yellow-400 drop-shadow-[0_0_8px_rgba(234,179,8,0.5)]" /> : 
                     index === 1 ? <Medal className="w-4 h-4 mx-auto text-zinc-300 drop-shadow-[0_0_8px_rgba(212,212,216,0.5)]" /> : 
                     index === 2 ? <Medal className="w-4 h-4 mx-auto text-amber-600" /> : 
                     <span className="text-zinc-500">#{index + 1}</span>}
                  </TableCell>
                  <TableCell className="font-medium text-white tracking-wide font-mono">
                    {player.PlayerName}
                  </TableCell>
                  {isDalgona && (
                    <TableCell className="text-center">
                      <span className={`text-xs font-mono px-2 py-1 rounded border ${
                        player.Difficulty === 'Hard' ? 'bg-rose-950/40 text-rose-400 border-rose-500/30' :
                        player.Difficulty === 'Medium' ? 'bg-amber-950/40 text-amber-400 border-amber-500/30' :
                        'bg-teal-950/40 text-teal-400 border-teal-500/30'
                      }`}>
                        {player.Difficulty || 'Easy'}
                      </span>
                    </TableCell>
                  )}
                  <TableCell className="text-right">
                    <Badge 
                      variant={index < 3 ? "default" : "secondary"} 
                      className={`font-mono ${
                        index < 3 
                          ? "bg-rose-600 text-white border-rose-500 shadow-[0_0_10px_rgba(225,29,72,0.4)]" 
                          : "bg-zinc-900 text-teal-400 border border-teal-500/30"
                      }`}
                    >
                      {isDalgona ? player.Score.toFixed(2) : Math.floor(player.Score)}
                    </Badge>
                  </TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </div>
    );
  };

  return (
    <div className="max-w-4xl mx-auto p-6 space-y-8 text-zinc-50">
      
      {/* Back Link */}
      <Link 
        href="/" 
        className="inline-flex items-center gap-2 text-sm font-medium text-zinc-400 transition-colors hover:text-rose-400 font-mono tracking-wider"
      >
        <ArrowLeft className="h-4 w-4" />
        Back to Portal
      </Link>
      
      {/* Header section */}
      <div className="flex flex-col gap-1.5 border-b border-rose-500/20 pb-4">
        <h1 className="text-3xl font-extrabold tracking-wider text-white uppercase font-mono">
          Participant Standings
        </h1>
        <p className="text-sm text-teal-400 font-mono">
          Live encrypted terminal for active game trials.
        </p>
      </div>

      <Tabs defaultValue="sipa" className="w-full">
        <TabsList className="grid w-full max-w-md grid-cols-2 bg-zinc-950/80 border border-rose-500/30 p-1 rounded-xl h-auto">
          <TabsTrigger 
            value="sipa" 
            className="flex items-center gap-2 font-mono text-xs uppercase tracking-wider py-2.5 text-zinc-400 data-[state=active]:bg-rose-600 data-[state=active]:text-white data-[state=active]:shadow-[0_0_15px_rgba(225,29,72,0.4)] transition-all"
          >
            <Activity className="w-4 h-4 text-teal-400 data-[state=active]:text-white" />
            Trial 01: Sipa
          </TabsTrigger>
          <TabsTrigger 
            value="dalgona" 
            // disabled
            className="flex items-center gap-2 font-mono text-xs uppercase tracking-wider py-2.5 text-zinc-400 data-[state=active]:bg-rose-600 data-[state=active]:text-white data-[state=active]:shadow-[0_0_15px_rgba(225,29,72,0.4)] transition-all"
          >
            <Clock className="w-4 h-4 text-teal-400 data-[state=active]:text-white" />
            Trial 02: Dalgona
          </TabsTrigger>
        </TabsList>
        
        <TabsContent value="sipa" className="mt-6">
          <Card className="border-rose-500/30 shadow-[0_0_30px_rgba(225,29,72,0.15)] bg-zinc-950/90 backdrop-blur-md">
            <CardHeader>
              <CardTitle className="text-xl font-bold font-mono tracking-wide text-white">
                Sipa Leaderboard
              </CardTitle>
              <CardDescription className="text-zinc-400 font-mono text-xs">
                Top scores ranked by consecutive successful aerial kicks.
              </CardDescription>
            </CardHeader>
            <CardContent>
              {renderTable(sipaScores, 'SIPA')}
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="dalgona" className="mt-6">
          <Card className="border-rose-500/30 shadow-[0_0_30px_rgba(225,29,72,0.15)] bg-zinc-950/90 backdrop-blur-md">
            <CardHeader>
              <CardTitle className="text-xl font-bold font-mono tracking-wide text-white">
                Dalgona Leaderboard
              </CardTitle>
              <CardDescription className="text-zinc-400 font-mono text-xs">
                Top scores ranked by the fastest completion time.
              </CardDescription>
            </CardHeader>
            <CardContent>
              {renderTable(dalgonaScores, 'DALGONA')}
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
}