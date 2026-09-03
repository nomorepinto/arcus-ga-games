import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, QueryCommand } from "@aws-sdk/lib-dynamodb";
import { NextResponse } from "next/server";

const client = new DynamoDBClient({
  region: process.env.AWS_REGION,
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  },
});
const docClient = DynamoDBDocumentClient.from(client);

export async function GET(request) {
  const { searchParams } = new URL(request.url);
  const gameId = searchParams.get("game") || "SIPA";
  const limit = parseInt(searchParams.get("limit") || "10", 10);

  const isDalgona = gameId.toUpperCase() == "DALGONA";

  try {
    const response = await docClient.send(new QueryCommand({
      TableName: process.env.DYNAMODB_TABLE_NAME,
      IndexName: "LeaderboardIndex",
      KeyConditionExpression: "PK = :pk",
      ExpressionAttributeValues: {
        ":pk": `GAME#${gameId.toUpperCase()}`,
      },
      ScanIndexForward: false, // Descending order
    }));

    let items = response.Items || [];

    // Sort explicitly in JavaScript
    if (isDalgona) {
      // Ascending for Dalgona
      items.sort((a, b) => Number(a.Score) - Number(b.Score));
    } else {
      // Descending for Sipa
      items.sort((a, b) => Number(b.Score) - Number(a.Score));
    }

    // Apply the limit after sorting
    const limitedItems = items.slice(0, limit);

    return NextResponse.json({ data: response.Items }, { status: 200 });
  } catch (error) {
    console.error("DynamoDB Error:", error);
    return NextResponse.json({ error: "Failed to fetch leaderboard." }, { status: 500 });
  }
}