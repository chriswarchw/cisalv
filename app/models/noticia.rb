class Noticia < ApplicationRecord
  self.table_name = "noticias"

  scope :publicadas, -> { where(publicado: true).order(data_publicacao: :desc) }
  scope :destaques, -> { where(publicado: true).where("ordem > 0").order(ordem: :asc) }

  def self.list_publicadas
    where(publicado: true).order(data_publicacao: :desc)
  end

  before_save :update_search_vector, :generate_slug

  def conteudo_dinamico
    @conteudo_dinamico ||= begin
      require "google/apis/drive_v3"
      GoogleDocsService.new.get_document_html(google_doc_id)
    end
  end

  def self.buscar(query)
    return none if query.blank?

    sanitized = ActiveRecord::Base.sanitize_sql_like(query)

    where(
      "
      search_vector @@ plainto_tsquery('portuguese', :query)
      OR titulo ILIKE :like_q
      ",
      query: query,
      like_q: "%#{sanitized}%"
    ).order(
      Arel.sql("ts_rank(search_vector, plainto_tsquery('portuguese', '#{sanitized}')) DESC"),
      data_publicacao: :desc
    )
  end

  def self.find_by_slug(slug)
    find_by(slug: slug)
  end

  def link_drive
    "https://docs.google.com/document/d/#{google_doc_id}/edit"
  end

  private

  def generate_slug
    self.slug = titulo.parameterize if titulo.present? && slug.blank?
  end

  def update_search_vector
    texto = [ titulo, conteudo_html, resumo ].compact.join(" ")

    vec = ActiveRecord::Base.connection.execute(
      "SELECT to_tsvector('portuguese', unaccent(#{ActiveRecord::Base.connection.quote(texto)})) as vec"
    ).first["vec"]

    self.search_vector = vec
  end
end
