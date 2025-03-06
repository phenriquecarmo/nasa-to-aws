import json
import boto3
import requests
import os

s3_client = boto3.client("s3")

S3_BUCKET = os.environ["S3_BUCKET_NAME"]

def download_image(url, file_path):
    response = requests.get(url, stream=True)
    if response.status_code == 200:
        with open(file_path, "wb") as file:
            for chunk in response.iter_content(1024):
                file.write(chunk)
    else:
        raise Exception(f"Failed to download image, status code: {response.status_code}")

def upload_to_s3(file_path, s3_key):
    """Upload image to S3 bucket."""
    s3_client.upload_file(file_path, S3_BUCKET, s3_key)
    print(f"Image uploaded to S3: s3://{S3_BUCKET}/{s3_key}")

def lambda_handler(event, context):
    for record in event["Records"]:
        message = json.loads(record["body"])
        image_url = message["url"]
        image_filename = image_url.split("/")[-1]

        local_path = f"/tmp/{image_filename}"
        s3_key = image_filename

        try:
            print(f"Downloading image from {image_url}...")
            download_image(image_url, local_path)

            print(f"Uploading image to S3...")
            upload_to_s3(local_path, s3_key)

            return {"statusCode": 200, "body": f"Image {s3_key} uploaded successfully."}

        except Exception as e:
            print(f"Error: {str(e)}")
            return {"statusCode": 500, "body": f"Error processing image: {str(e)}"}