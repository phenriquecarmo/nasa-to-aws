import json
import boto3
import os
import psycopg2
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email import encoders

s3 = boto3.client("s3")
ses = boto3.client("ses")
secretsmanager = boto3.client("secretsmanager")

def get_db_credentials(secret_name: str, region_name: str = "sa-east-1") -> dict:
    secret_value = secretsmanager.get_secret_value(SecretId=secret_name)
    return json.loads(secret_value["SecretString"])

def fetch_active_subscriber_emails(conn) -> list:
    with conn.cursor() as cur:
        cur.execute("SELECT email FROM subscribers WHERE is_active = TRUE AND unsubscribed_at IS null AND subscription_confirmed = TRUE;")
        return [row[0] for row in cur.fetchall()]

def lambda_handler(event, context):
    print("Received event:", json.dumps(event, indent=2))
    
    db_secret_name = os.getenv("DB_SECRET_NAME")
    ses_sender_email = os.getenv("SES_SENDER_EMAIL")

    db_creds = get_db_credentials(db_secret_name)

    try:
        conn = psycopg2.connect(
            dbname=db_creds["dbname"],
            user=db_creds["username"],
            password=db_creds["password"],
            host=db_creds["host"],
            port=db_creds["port"]
        )
    except Exception as e:
        print("Database connection error:", e)
        return {"statusCode": 500, "body": "Database connection failed"}

    try:
        emails = fetch_active_subscriber_emails(conn)
        print(f"Sending email to {len(emails)} active subscribers.")

        for record in event["Records"]:
            sns_message = json.loads(record["Sns"]["Message"])
            s3_record = sns_message["Records"][0]
            bucket_name = s3_record["s3"]["bucket"]["name"]
            object_key = s3_record["s3"]["object"]["key"]

            local_path = f"/tmp/{object_key}"
            s3.download_file(bucket_name, object_key, local_path)

            subject = "🚀 NASA Image of the Day!"
            body_text = (
                f"Hello!\n\nA new NASA image has been uploaded:\n\n"
                f"🛰️ Bucket: {bucket_name}\n📂 File: {object_key}\n\nEnjoy the view! 🌌"
            )

            msg = MIMEMultipart()
            msg["Subject"] = subject
            msg["From"] = ses_sender_email
            msg.attach(MIMEText(body_text, "plain"))

            with open(local_path, "rb") as attachment:
                part = MIMEBase("application", "octet-stream")
                part.set_payload(attachment.read())
                encoders.encode_base64(part)
                part.add_header("Content-Disposition", f'attachment; filename="{object_key}"')
                msg.attach(part)

            for email in emails:
                msg["To"] = email
                response = ses.send_raw_email(
                    Source=ses_sender_email,
                    Destinations=[email],
                    RawMessage={"Data": msg.as_string()}
                )
                print(f"Email sent to {email}: {response['MessageId']}")

        return {"statusCode": 200, "body": "Emails sent!"}

    except Exception as e:
        print("Error during Lambda execution:", e)
        return {"statusCode": 500, "body": str(e)}

    finally:
        conn.close()
