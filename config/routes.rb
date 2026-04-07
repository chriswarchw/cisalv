Rails.application.routes.draw do
  get "noticias", to: "noticias#index"
  get "noticias/:slug", to: "noticias#show"
  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  root "pages#home"
  get "compras", to: "compras#index"

  get "*path" => "pages#not_found"
end
