import os
import io
from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload, MediaIoBaseDownload

# Set up your Google Drive API client
def initialize_drive_service():
    # Load the service account credentials
    creds = service_account.Credentials.from_service_account_file(
        'carpart-6ed9b-b0968f704e92.json',
        scopes=['https://www.googleapis.com/auth/drive']
    )
    return build('drive', 'v3', credentials=creds)

# Function to upload multiple files to Google Drive
def upload_files(service, file_paths):
    for file_path in file_paths:
        file_metadata = {
            'name': os.path.basename(file_path)
        }
        media = MediaFileUpload(file_path)
        file = service.files().create(body=file_metadata, media_body=media, fields='id').execute()
        print(f"Uploaded {file_path} with ID: {file.get('id')}")

# Function to read multiple files from Google Drive
def read_files(service, file_ids):
    for file_id in file_ids:
        request = service.files().get_media(fileId=file_id)
        fh = io.BytesIO()
        downloader = MediaIoBaseDownload(fh, request)
        done = False
        while done is False:
            status, done = downloader.next_chunk()
            print(f"Download {int(status.progress() * 100)}%.")

        fh.seek(0)
        print(f"Content of file ID {file_id}:")
        print(fh.read().decode('utf-8'))

if __name__ == "__main__":
    # Initialize the Google Drive service
    drive_service = initialize_drive_service()

    # List of file paths to upload
    files_to_upload = [
        "examples/InvoiceSimplified/output/0000004_Signed.xml"
    ]

    # Upload files
    upload_files(drive_service, files_to_upload)

    # List of file IDs to read (you need to replace these with actual file IDs)
    # files_to_read = [
    #     "your_file_id_1",
    #     "your_file_id_2",
    #     "your_file_id_3"
    # ]
    #
    # # Read files
    # read_files(drive_service, files_to_read)

