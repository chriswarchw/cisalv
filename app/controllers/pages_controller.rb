class PagesController < ApplicationController
  def home
    @noticias = Noticia.list_publicadas.limit(5)
    @instagram_posts = fetch_instagram_posts
  end

  def not_found
    render file: "#{Rails.root}/public/404.html", layout: false, status: :not_found
  end

  private

  def fetch_instagram_posts
    token = ENV["INSTAGRAM_ACCESS_TOKEN"] || "IGAANPdZBDdZCIFBZAGJjUFlzUXNhQ3A3WktId0tsUjNpMk1jUDF3ZAXBxNlg4ZADE3c0lyNVpSUUtTSUVwb05mZA25LQ3k0aXFaOWsxMnVCRnhnRFJTejlfQTV5SUVjNVM5MUxXbkViZAlExN3htcG8wcFRqR2tBU3ZAjWnNqR1hJT05YawZDZD"

    begin
      InstagramService.new(token).fetch_media(limit: 6)
    rescue => e
      Rails.logger.error "Instagram fetch error: #{e.message}"
      []
    end
  end
end
