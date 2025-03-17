import json
import boto3
import os

ses = boto3.client('ses')

def lambda_handler(event, context):
    print("Received event:", json.dumps(event, indent=2))

    for record in event['Records']:
        sns_message = record['Sns']['Message']
        subject = "S3 Notification: New File Uploaded"
        recipient = os.getenv("SES_RECIPIENT_EMAIL")
        sender = os.getenv("SES_SENDER_EMAIL")

        response = ses.send_email(
            Source=sender,
            Destination={'ToAddresses': [recipient]},
            Message={
                'Subject': {'Data': subject},
                'Body': {'Text': {'Data': sns_message}}
            }
        )

    return {"statusCode": 200, "body": json.dumps("Email sent successfully!")}