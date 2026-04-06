class SincronizarDiariosJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: :exponentially_longer, attempts: 3

  FOLDER_IDS = [
    "1Ixy8g08V12KV_g3IbH7yg0y0L005sL_D",  # Pasta 1
    "1aB8HTcPV-E2pmT70P0QI-UBQfyndnN8f"   # Pasta 2
  ].freeze

  def perform
    Rails.logger.info "=== INICIANDO SINCRONIZAÇÃO DE DIÁRIOS ==="

    ocr_service = OcrService.new
    pdfs_dir = Rails.root.join("tmp", "diarios")
    FileUtils.mkdir_p(pdfs_dir)

    total_novos = 0
    total_atualizados = 0
    total_erros = 0

    FOLDER_IDS.each do |folder_id|
      Rails.logger.info "--- Sincronizando pasta: #{folder_id} ---"

      google_drive = GoogleDriveService.new(folder_id)
      pdfs = google_drive.list_all_pdfs

      Rails.logger.info "Encontrados #{pdfs.length} PDFs"

      pdfs.each do |pdf|
        begin
          result = processar_pdf(pdf, google_drive, ocr_service, pdfs_dir)
          total_novos += 1 if result == :novo
          total_atualizados += 1 if result == :atualizado
        rescue => e
          Rails.logger.error "Erro ao processar #{pdf.name}: #{e.message}"
          total_erros += 1
        end
      end
    end

    Rails.logger.info "=== SINCRONIZAÇÃO CONCLUÍDA ==="
    Rails.logger.info "Total Novos: #{total_novos} | Atualizados: #{total_atualizados} | Erros: #{total_erros}"

    FileUtils.rm_rf(pdfs_dir)
  end

  private

  def processar_pdf(pdf, google_drive, ocr_service, pdfs_dir)
    drive_modified = Time.parse(pdf.modified_time)

    diario = Diario.find_or_initialize_by(drive_file_id: pdf.id)

    if diario.persisted? && diario.drive_modified_at >= drive_modified
      Rails.logger.debug "Pulando (não modificado): #{pdf.name}"
      return nil
    end

    diario.assign_attributes(
      drive_web_view_link: pdf.web_view_link,
      drive_web_content_link: pdf.web_content_link,
      filename: pdf.name,
      file_size: pdf.size.to_i,
      mime_type: pdf.mime_type,
      drive_modified_at: drive_modified
    )

    titulo = extrair_titulo(pdf.name)
    diario.titulo = titulo if titulo.present?
    diario.data_publicacao = extrair_data(pdf.name) if diario.data_publicacao.blank?

    if diario.ocr_pendente? || diario.conteudo_ocr.blank?
      pdf_path = pdfs_dir.join("#{pdf.id}.pdf")
      google_drive.download_file(pdf.id, pdf_path.to_s)

      Rails.logger.info "Processando OCR: #{pdf.name}"
      diario.conteudo_ocr = ocr_service.extract_text_from_pdf(pdf_path.to_s)
      diario.conteudo_texto = ocr_service.extract_text_native(pdf_path.to_s)
      diario.ocr_pendente = false
    end

    diario.processado = true
    diario.erro_processamento = nil
    diario.save!

    Rails.logger.info "Indexado: #{pdf.name}"

    diario.created_at == diario.updated_at ? :novo : :atualizado
  rescue => e
    diario.update(erro_processamento: e.message) if diario.persisted?
    raise e
  end

  def extrair_titulo(filename)
    filename.gsub(/\.pdf$/i, "").strip
  end

  def extrair_data(filename)
    match = filename.match(/(\d{2})[\/_-](\d{2})[\/_-](\d{4})/)
    return nil unless match

    Date.strptime("#{match[1]}/#{match[2]}/#{match[3]}", "%d/%m/%Y")
  rescue
    nil
  end
end
