namespace :diarios do
  desc "Sincroniza diários do Google Drive e processa OCR"
  task sincronizar: :environment do
    puts "Iniciando sincronização de diários..."
    SincronizarDiariosJob.perform_now
    puts "Sincronização concluída!"
  end

  desc "Processa OCR de diários pendentes"
  task processar_ocr: :environment do
    diarios = Diario.pendentes_ocr
    puts "Processando #{diarios.count} diários pendentes..."

    ocr_service = OcrService.new
    pdfs_dir = Rails.root.join("tmp", "diarios")
    FileUtils.mkdir_p(pdfs_dir)

    diarios.find_each do |diario|
      begin
        pdf_path = pdfs_dir.join("#{diario.drive_file_id}.pdf")
        GoogleDriveService.new.download_file(diario.drive_file_id, pdf_path.to_s)

        diario.conteudo_ocr = ocr_service.extract_text_from_pdf(pdf_path.to_s)
        diario.ocr_pendente = false
        diario.save!

        FileUtils.rm(pdf_path)
        puts "Processado: #{diario.titulo}"
      rescue => e
        puts "Erro em #{diario.titulo}: #{e.message}"
      end
    end

    FileUtils.rm_rf(pdfs_dir)
    puts "Processamento OCR concluído!"
  end

  desc "Testa busca de diários"
  task buscar: :environment do
    query = ENV["QUERY"] || "contrato"
    puts "Buscando: #{query}"
    puts "-" * 50

    Diario.busca(query).each do |d|
      puts "ID: #{d.id}"
      puts "Título: #{d.titulo}"
      puts "Data: #{d.data_publicacao}"
      puts "Link: #{d.link_drive}"
      puts "-" * 50
    end
  end
end
