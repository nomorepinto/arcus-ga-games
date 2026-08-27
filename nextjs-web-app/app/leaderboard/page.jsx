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
  // const [dalgonaScores, setDalgonaScores] = useState([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    async function fetchLeaderboards() {
      try {
        // Fetch Sipa scores
        const sipaRes = await fetch('/api/leaderboard?game=SIPA', { cache: 'no-store' });
        const sipaData = await sipaRes.json();
        setSipaScores(sipaData.data || []);

        /* 
        // Commented out until DALGONA items are initialized in DynamoDB
        const dalgonaRes = await fetch('/api/score?game=DALGONA');
        const dalgonaData = await dalgonaRes.json();
        setDalgonaScores(dalgonaData.Items || []);
        */
      } catch (error) {
        console.error("Failed to fetch scores", error);
      } finally {
        setIsLoading(false);
      }
    }

    fetchLeaderboards();
  }, []);

  const renderTable = (scores, gameType) => (
    <div className="rounded-md border border-zinc-200 dark:border-zinc-800">
      <Table>
        <TableHeader className="bg-zinc-50 dark:bg-zinc-900/50">
          <TableRow>
            <TableHead className="w-16 text-center">Rank</TableHead>
            <TableHead>Player</TableHead>
            <TableHead className="text-right">
              {gameType === 'SIPA' ? 'Kicks' : 'Time (s)'}
            </TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {scores.length === 0 ? (
            <TableRow>
              <TableCell colSpan={3} className="h-24 text-center text-zinc-500">
                {isLoading ? 'Loading scores...' : 'No scores found.'}
              </TableCell>
            </TableRow>
          ) : (
            scores.map((player, index) => (
              <TableRow key={player.PlayerId || index} className="hover:bg-zinc-50 dark:hover:bg-zinc-900/50 transition-colors">
                <TableCell className="text-center font-medium">
                  {index === 0 ? <Trophy className="w-4 h-4 mx-auto text-yellow-500" /> : 
                   index === 1 ? <Medal className="w-4 h-4 mx-auto text-zinc-400" /> : 
                   index === 2 ? <Medal className="w-4 h-4 mx-auto text-amber-600" /> : 
                   index + 1}
                </TableCell>
                <TableCell className="font-medium text-zinc-900 dark:text-zinc-100">
                  {player.PlayerName}
                </TableCell>
                <TableCell className="text-right">
                  <Badge variant={index < 3 ? "default" : "secondary"} className="font-mono">
                    {gameType === 'SIPA' ? Math.floor(player.Score) : player.Score.toFixed(2)}
                  </Badge>
                </TableCell>
              </TableRow>
            ))
          )}
        </TableBody>
      </Table>
    </div>
  );

  return (
    <div className="max-w-4xl mx-auto p-6 space-y-8">
      <Link 
        href="/" 
        className="inline-flex items-center gap-2 text-sm font-medium text-zinc-500 transition-colors hover:text-zinc-900 dark:text-zinc-400 dark:hover:text-zinc-50"
      >
        <ArrowLeft className="h-4 w-4" />
        Back to Portal
      </Link>
      
      <div className="flex flex-col gap-2">
        <h1 className="text-3xl font-semibold tracking-tight text-zinc-900 dark:text-zinc-50">Organization Rankings</h1>
        <p className="text-zinc-500 dark:text-zinc-400">Real-time leaderboard for active game modes.</p>
      </div>

      <Tabs defaultValue="sipa" className="w-full">
        <TabsList className="grid w-full max-w-md grid-cols-2">
          <TabsTrigger value="sipa" className="flex items-center gap-2">
            <Activity className="w-4 h-4" />
            Sipa
          </TabsTrigger>
          <TabsTrigger value="dalgona" disabled className="flex items-center gap-2 opacity-50 cursor-not-allowed">
            <Clock className="w-4 h-4" />
            Dalgona (Coming Soon)
          </TabsTrigger>
        </TabsList>
        
        <TabsContent value="sipa" className="mt-6">
          <Card className="border-zinc-200 shadow-sm dark:border-zinc-800">
            <CardHeader>
              <CardTitle>Sipa Leaderboard</CardTitle>
              <CardDescription>Top scores based on consecutive kicks.</CardDescription>
            </CardHeader>
            <CardContent>
              {renderTable(sipaScores, 'SIPA')}
            </CardContent>
          </Card>
        </TabsContent>

        {/* 
        <TabsContent value="dalgona" className="mt-6">
          <Card className="border-zinc-200 shadow-sm dark:border-zinc-800">
            <CardHeader>
              <CardTitle>Dalgona Cookie</CardTitle>
              <CardDescription>Fastest completion times without breaking the shape.</CardDescription>
            </CardHeader>
            <CardContent>
              {renderTable(dalgonaScores, 'DALGONA')}
            </CardContent>
          </Card>
        </TabsContent> 
        */}
      </Tabs>
    </div>
  );
}