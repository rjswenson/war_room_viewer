ActiveAdmin.register Game do
  menu parent: 'Components'
  actions :index, :edit, :create, :update, :new, :show, :destroy
  #:duplicate, :preview, :publish
  config.filters = false

  def permitted_params
    params.require(:game).permit!
  end

  index do
    selectable_column
    column :name
    column :key
    column :year
    column :tags
    actions
  end

  show do
    attributes_table do
      row :name
      row :key
      row :year
      row :tags
    end
  end
end