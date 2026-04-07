namespace :noticias do
  desc "Sincroniza notícias do Google Drive"
  task sincronizar: :environment do
    puts "Iniciando sincronização de notícias..."
    folder_id = ENV["FOLDER_ID"] || "1IKY9ivBLABdWPh2ALp-i9jU3zk71Uw9M"
    SincronizarNoticiasJob.perform_now(folder_id)
    puts "Sincronização concluída!"
  end
end
