class Diario < ApplicationRecord
  scope :pendentes_ocr, -> { where(ocr_pendente: true, processado: false) }
  scope :processados, -> { where(processado: true) }

  def self.search(query)
    return none if query.blank?

    sanitized = ActiveRecord::Base.sanitize_sql_like(query)

    where(
      "
      search_vector @@ plainto_tsquery('portuguese', :query)
      OR similarity(unaccent(titulo), unaccent(:query)) > 0.2
      OR similarity(unaccent(filename), unaccent(:query)) > 0.2
      OR titulo ILIKE :like_q
      OR filename ILIKE :like_q
      ",
      query: query,
      like_q: "%#{sanitized}%"
    ).order(
      Arel.sql("ts_rank(search_vector, plainto_tsquery('portuguese', '#{sanitized}')) DESC"),
      Arel.sql("similarity(unaccent(titulo), unaccent('#{sanitized}')) DESC"),
      Arel.sql("data_publicacao DESC")
    )
  end

  def self.busca(query, limit: 20)
    search(query).limit(limit)
  end

  def link_drive
    drive_web_view_link || "https://drive.google.com/file/d/#{drive_file_id}/view"
  end

  def snippet(limit: 200)
    texto = conteudo_ocr || conteudo_texto || ""
    return "" if texto.blank?
    texto.truncate(limit, separator: " ")
  end

  before_save :update_search_vector

  private

  def update_search_vector
    texto = [ titulo, conteudo_texto, conteudo_ocr, filename ].compact.join(" ")

    vec = ActiveRecord::Base.connection.execute(
      "SELECT to_tsvector('portuguese', unaccent(#{ActiveRecord::Base.connection.quote(texto)})) as vec"
    ).first["vec"]

    self.search_vector = vec
  end
end
