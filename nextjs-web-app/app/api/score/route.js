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
        Score: body.Score,
        Difficulty: body.Difficulty || "Normal"
      },
    }));

    return NextResponse.json({ message: "Score saved successfully." }, { status: 200 });
  } catch (error) {
    console.error("DynamoDB Error:", error);
    return NextResponse.json({ error: "Failed to save score." }, { status: 500 });
  }
}