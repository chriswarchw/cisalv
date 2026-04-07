class SincronizarNoticiasJob < ApplicationJob
  queue_as :default

  def perform(folder_id = nil)
    service = GoogleDocsService.new(folder_id)
    service.sync_all
  end
end
