class CreateNoticias < ActiveRecord::Migration[7.2]
  def change
    create_table :noticias do |t|
      t.string :google_doc_id, null: false, index: { unique: true }
      t.string :titulo
      t.text :conteudo_html
      t.text :resumo
      t.string :imagem_destaque
      t.string :autor
      t.datetime :data_publicacao
      t.boolean :publicado, default: true
      t.integer :ordem, default: 0
      t.tsvector :search_vector

      t.timestamps
    end

    add_index :noticias, :search_vector, using: 'gin'
    add_index :noticias, :publicado
    add_index :noticias, :data_publicacao
  end
end
