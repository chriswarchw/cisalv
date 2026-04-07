class NoticiasController < ApplicationController
  def index
    @noticias = Noticia.where(publicado: true).order(data_publicacao: :desc).page(params[:page]).per(5)
  end

  def show
    @noticia = Noticia.find_by_slug(params[:slug])
    render file: Rails.root.join("public/404.html"), status: :not_found unless @noticia
  end
end
