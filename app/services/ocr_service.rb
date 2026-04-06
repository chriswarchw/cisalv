class OcrService
  PDFIMAGES_PATH = "/usr/bin/pdfimages"
  TESSERACT_PATH = "/usr/bin/tesseract"
  PDFTOTEXT_PATH = "/usr/bin/pdftotext"
  TEMP_DIR = Rails.root.join("tmp", "ocr")

  def initialize
    FileUtils.mkdir_p(TEMP_DIR)
  end

  def extract_text_from_pdf(pdf_path)
    Rails.logger.info "Iniciando OCR de: #{pdf_path}"

    texto_total = []

    texto_imagens = extract_text_from_images(pdf_path)
    texto_total << texto_imagens if texto_imagens.present?

    Rails.logger.info "OCR: Extraídos #{texto_total.sum(&:length)} caracteres (imagens)"
    texto_total.join("\n\n")
  rescue => e
    Rails.logger.error "Erro no OCR: #{e.message}"
    raise e
  ensure
    cleanup_temp_files
  end

  def extract_text_native(pdf_path)
    Rails.logger.info "Extraindo texto nativo de: #{pdf_path}"

    command = "#{PDFTOTEXT_PATH} -layout #{pdf_path} -"
    result = `#{command} 2>/dev/null`
    result.encode("UTF-8", invalid: :replace, undef: :replace, replace: "")

    Rails.logger.info "Texto nativo: #{result.length} caracteres"
    result
  rescue => e
    Rails.logger.error "Erro ao extrair texto nativo: #{e.message}"
    ""
  end

  private

  def extract_text_from_images(pdf_path)
    basename = File.basename(pdf_path, ".pdf")
    output_prefix = TEMP_DIR.join(basename)

    command = "#{PDFIMAGES_PATH} -png #{pdf_path} #{output_prefix}"
    Rails.logger.debug "Executando: #{command}"

    system(command, out: File::NULL, err: File::NULL)

    imagens = Dir.glob("#{output_prefix}-*.png").sort

    return "" if imagens.empty?

    Rails.logger.info "Encontradas #{imagens.length} imagens para OCR"

    textos = imagens.map do |img|
      result = `#{TESSERACT_PATH} #{img} stdout -l por 2>/dev/null`
      result.encode("UTF-8", invalid: :replace, undef: :replace, replace: "")
      result.strip
    end

    FileUtils.rm(imagens, force: true)

    textos.reject(&:blank?).join("\n\n")
  end

  def cleanup_temp_files
    Dir.glob("#{TEMP_DIR}/*").each do |f|
      FileUtils.rm_f(f)
    end
  end
end
