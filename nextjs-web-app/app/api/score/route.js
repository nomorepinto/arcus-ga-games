import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, PutCommand } from "@aws-sdk/lib-dynamodb";
import { NextResponse } from "next/server";

const client = new DynamoDBClient({
  region: process.env.AWS_REGION,
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  },
});
const docClient = DynamoDBDocumentClient.from(client);

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