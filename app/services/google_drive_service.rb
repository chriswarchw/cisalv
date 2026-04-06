require "googleauth"
require "google/apis/drive_v3"

class GoogleDriveService
  def initialize(folder_id = nil)
    @folder_id = folder_id || ENV["GOOGLE_DRIVE_FOLDER_ID"] || "1Ixy8g08V12KV_g3IbH7yg0y0L005sL_D"
    @drive = Google::Apis::DriveV3::DriveService.new
  end

  def authorization
    @authorization ||= begin
      Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: File.open(Rails.root.join("config", "diario-service-account.json")),
        scope: [ "https://www.googleapis.com/auth/drive.readonly" ]
      ).tap(&:fetch_access_token!)
    end
  end

  def list_pdfs(page_size: 100)
    @drive.authorization = authorization
    response = @drive.list_files(
      q: "'#{@folder_id}' in parents and mimeType='application/pdf' and trashed=false",
      fields: "files(id, name, mimeType, webViewLink, webContentLink, size, modifiedTime, createdTime),nextPageToken",
      order_by: "modifiedTime desc",
      supports_all_drives: true,
      include_items_from_all_drives: true,
      page_size: page_size
    )
    response.files
  end

  def list_all_pdfs
    all_files = []
    page_token = nil

    loop do
      @drive.authorization = authorization
      response = @drive.list_files(
        q: "'#{@folder_id}' in parents and mimeType='application/pdf' and trashed=false",
        fields: "files(id, name, mimeType, webViewLink, webContentLink, size, modifiedTime, createdTime),nextPageToken",
        order_by: "modifiedTime desc",
        supports_all_drives: true,
        include_items_from_all_drives: true,
        page_size: 100,
        page_token: page_token
      )
      all_files += response.files
      page_token = response.next_page_token
      break unless page_token
    end

    all_files
  end

  def download_file(file_id, destination_path)
    @drive.authorization = authorization
    @drive.get_file(
      file_id,
      download_dest: destination_path,
      supports_all_drives: true
    )
  end

  def get_file_metadata(file_id)
    @drive.authorization = authorization
    @drive.get_file(
      file_id,
      fields: "id, name, mimeType, webViewLink, webContentLink, size, modifiedTime, createdTime",
      supports_all_drives: true
    )
  end

  def file_exists?(file_id)
    get_file_metadata(file_id)
    true
  rescue Google::Apis::ClientError
    false
  end
end
