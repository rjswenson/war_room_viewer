ActiveAdmin.register Species do
  menu parent: 'Components'
  actions :index, :edit, :create, :update, :new, :show, :destroy
  #:duplicate, :preview, :publish
  config.filters = false

  def permitted_params
    params.require(:species).permit!
  end

  index do
    selectable_column
    column :name
    column :key
    column :home_planet
    actions
  end

  show do
    attributes_table do
      row :name
      row :key
      row :home_planet
    end

  end
end
