# Arcus General Assembly Minigames

This repository houses the web application and backend infrastructure for **Sipa** and **Dalgona Cookie Cutting**, a series of 2D web games built with Godot 4 and seamlessly integrated into a Next.js environment.

## Features & Architecture

- **2D Gameplay**: Utilizes Godot's 2D features, such as collision detection for core gameplay mechanics and boundary handling.
- **Next.js API Integration**: Custom backend API routes handle secure data transfer directly between the WebGL game canvas and the server.
- **Global Leaderboard**: Powered by AWS DynamoDB, allowing players to fetch real-time high scores and submit entries upon game over.
- **Browser-Compliant Audio**: Implements a pre-game interactive menu scene to securely unlock the Web Audio API Context required by modern browsers.

## Tech Stack

- **Frontend Game**: Godot Engine 4 (GDScript, WebGL/WASM)
- **Web Framework**: Next.js (React)
- **Database**: AWS DynamoDB (via `@aws-sdk`)
- **UI & Overlays**: Godot Control Nodes and dynamic HTML/CSS canvas integrations

## Local Development Setup

1. Clone this repository and navigate to the Next.js web application directory.
2. Install all required dependencies by running:
   ```bash
   npm install
   ```
3. Create a `.env.local` file in the root directory and define your AWS credentials (e.g., `AWS_REGION`, `AWS_ACCESS_KEY_ID`).
4. Export the Godot project for the Web. Ensure all export files (including the `.wasm`, `.js`, and `sipa_export.audio.worklet.js` files) are placed securely inside the Next.js `public` directory.
5. Start the local development server using:
   ```bash
   npm run dev
   ```
