import json
import boto3
import os
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email import encoders

s3 = boto3.client("s3")
ses = boto3.client("ses")

def lambda_handler(event, context):
    print("Received event:", json.dumps(event, indent=2))  # Debugging

    for record in event["Records"]:
        sns_message = json.loads(record["Sns"]["Message"])

        s3_record = sns_message["Records"][0]  # First record inside SNS message
        bucket_name = s3_record["s3"]["bucket"]["name"]
        object_key = s3_record["s3"]["object"]["key"]

        subject = "🚀 NASA Image of the Day!"
        body_text = (
            f"Hello!\n\nA new NASA image has been uploaded:\n\n"
            f"🛰️ Bucket: {bucket_name}\n📂 File: {object_key}\n\nEnjoy the view! 🌌"
        )

        recipient = os.getenv("SES_RECIPIENT_EMAIL")
        sender = os.getenv("SES_SENDER_EMAIL")

        local_path = f"/tmp/{object_key}"
        s3.download_file(bucket_name, object_key, local_path)

        msg = MIMEMultipart()
        msg["Subject"] = subject
        msg["From"] = sender
        msg["To"] = recipient
        msg.attach(MIMEText(body_text, "plain"))

        with open(local_path, "rb") as attachment:
            part = MIMEBase("application", "octet-stream")
            part.set_payload(attachment.read())
            encoders.encode_base64(part)
            part.add_header("Content-Disposition", f'attachment; filename="{object_key}"')
            msg.attach(part)

        response = ses.send_raw_email(
            Source=sender,
            Destinations=[recipient],
            RawMessage={"Data": msg.as_string()},
        )

        print("Email sent successfully:", response)

    return {"statusCode": 200, "body": "Email with attachment sent!"}