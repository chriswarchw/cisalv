class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  rescue_from ActionController::RoutingError, with: :render_404

  private

  def render_404
    render file: "#{Rails.root}/public/404.html", layout: false, status: :not_found
  end
end
