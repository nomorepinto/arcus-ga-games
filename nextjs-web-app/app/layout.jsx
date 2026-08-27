import "./globals.css";
import { Inter } from "next/font/google";

const inter = Inter({ subsets: ["latin"] });

export const metadata = {
  title: "Arcus GA Minigames 2026",
  description: "Play Sipa and Dalgona Cookie",
};


export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body className={`${inter.className} min-h-screen bg-zinc-950 text-zinc-50 relative selection:bg-rose-600 selection:text-white`}>

        {/* Background Image Container with Dark Overlay */}
        <div 
          className="fixed inset-0 z-[-1] bg-cover bg-center bg-no-repeat opacity-50 pointer-events-none"
          style={{ backgroundImage: "url('/squid-bg.webp')" }}
        />

        {/* Balanced Radial Vignette Overlay */}
        <div className="fixed inset-0 z-[-1] bg-[radial-gradient(circle_at_center,transparent_20%,rgba(9,9,11,0.85)_90%)] pointer-events-none" />

        {/* Subtle Pink/Rose Neon Ambient Glow */}
        <div className="fixed inset-0 z-[-1] bg-rose-950/10 pointer-events-none mix-blend-color" />

        {/* Main Application Content */}
        <div className="relative z-10 flex min-h-screen flex-col">
          {children}
        </div>
      </body>
    </html>
  );
}