class CreateDiarios < ActiveRecord::Migration[7.2]
  def up
    enable_extension 'pg_trgm' unless extension_enabled?('pg_trgm')
    enable_extension 'unaccent' unless extension_enabled?('unaccent')

    create_table :diarios do |t|
      t.string :drive_file_id, null: false, index: { unique: true }
      t.string :drive_web_view_link
      t.string :drive_web_content_link
      t.string :titulo
      t.text :conteudo_texto
      t.text :conteudo_ocr
      t.date :data_publicacao
      t.string :filename
      t.integer :file_size
      t.string :mime_type
      t.datetime :drive_modified_at
      t.boolean :processado, default: false
      t.boolean :ocr_pendente, default: true
      t.text :erro_processamento
      t.tsvector :search_vector

      t.timestamps
    end

    add_index :diarios, :search_vector, using: 'gin'
    add_index :diarios, :data_publicacao
    add_index :diarios, :processado
    add_index :diarios, :titulo, using: 'gin', opclass: { titulo: 'gin_trgm_ops' }
  end

  def down
    drop_table :diarios
    disable_extension 'pg_trgm' if extension_enabled?('pg_trgm')
    disable_extension 'unaccent' if extension_enabled?('unaccent')
  end
end
