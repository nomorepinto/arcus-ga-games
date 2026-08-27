import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, PutCommand, QueryCommand } from "@aws-sdk/lib-dynamodb";
import { NextResponse } from "next/server";
export const dynamic = 'force-dynamic';

const client = new DynamoDBClient({
  region: process.env.AWS_REGION,
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  },
});
const docClient = DynamoDBDocumentClient.from(client);

// GET: Fetch the leaderboard
export async function GET(request) {
  try {
    const { searchParams } = new URL(request.url);
    const game = searchParams.get("game");

    if (!game) {
      return NextResponse.json({ error: "Game parameter is required." }, { status: 400 });
    }

    const data = await docClient.send(new QueryCommand({
      TableName: process.env.DYNAMODB_TABLE_NAME,
      KeyConditionExpression: "PK = :pk",
      ExpressionAttributeValues: {
        ":pk": game,
      },
    }));

    let sortedItems = data.Items || [];

    if (game === "DALGONA") {
      sortedItems.sort((a, b) => a.Score - b.Score);
    } else {
      sortedItems.sort((a, b) => b.Score - a.Score);
    }

    const top10 = sortedItems.slice(0, 10);

    return NextResponse.json({ Items: top10 }, { status: 200 });
  } catch (error) {
    console.error("DynamoDB GET Error:", error);
    return NextResponse.json({ error: "Failed to fetch leaderboard." }, { status: 500 });
  }
}

// POST: Save a new score
export async function POST(request) {
  try {
    const body = await request.json();
    
    await docClient.send(new PutCommand({
      TableName: process.env.DYNAMODB_TABLE_NAME,
      Item: {
        PK: body.PK,
        SK: body.SK,
        PlayerName: body.PlayerName,
        Score: body.Score
      },
    }));

    return NextResponse.json({ message: "Score saved successfully." }, { status: 200 });
  } catch (error) {
    console.error("DynamoDB Error:", error);
    return NextResponse.json({ error: "Failed to save score." }, { status: 500 });
  }
}