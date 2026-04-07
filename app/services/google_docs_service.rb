require "google/apis/drive_v3"

class GoogleDocsService
  BASE_URL = "https://docs.google.com"

  def initialize(folder_id = nil)
    @folder_id = folder_id || ENV["NEWS_FOLDER_ID"]
    @drive = Google::Apis::DriveV3::DriveService.new
  end

  def authorization
    @authorization ||= begin
      Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: File.open(Rails.root.join("config", "diario-service-account.json")),
        scope: [
          "https://www.googleapis.com/auth/drive.readonly",
          "https://www.googleapis.com/auth/documents.readonly"
        ]
      ).tap(&:fetch_access_token!)
    end
  end

  def list_docs
    @drive.authorization = authorization

    response = @drive.list_files(
      q: "'#{@folder_id}' in parents and mimeType='application/vnd.google-apps.document' and trashed=false",
      fields: "files(id, name, modifiedTime)",
      order_by: "modifiedTime desc",
      page_size: 50,
      supports_all_drives: true,
      include_items_from_all_drives: true
    )
    response.files
  end

  def get_document_html(doc_id)
    @drive.authorization = authorization
    html = @drive.export_file(doc_id, "text/html")

    if html.present?
      doc = Nokogiri::HTML(html)
      body = doc.at_css("body")
      body ? body.inner_html : html
    else
      nil
    end
  rescue => e
    Rails.logger.error "Erro ao exportar documento #{doc_id}: #{e.message}"
    nil
  end

  def sync_all
    docs = list_docs
    Rails.logger.info "Encontrados #{docs.length} documentos na pasta"

    docs.each do |doc|
      begin
        Noticia.find_or_initialize_by(google_doc_id: doc.id).tap do |noticia|
          noticia.titulo = doc.name
          noticia.data_publicacao = doc.modified_time.acts_like?(:time) ? doc.modified_time : Time.parse(doc.modified_time.to_s)
          noticia.publicado = true
          noticia.save!
        end
        Rails.logger.info "Sincronizado: #{doc.name}"
      rescue => e
        Rails.logger.error "Erro ao sincronizar #{doc.name}: #{e.message}"
      end
    end
  end
end
