ActiveAdmin.register Armor do
  menu parent: 'Components'
  actions :index, :edit, :create, :update, :new, :show, :destroy
  #:duplicate, :preview, :publish
  config.filters = false

  def permitted_params
    params.require(:armor).permit!
  end

  index do
    selectable_column
    column :icon
    column :name
    column :key
    column :type

    column :strength1
    column :strength2
    column :weakness1
    column :weakness2
    actions
  end

  show do
    attributes_table do
      row :icon
      row :name
      row :key
      row :type
      row :strength1
      row :strength2
      row :weakness1
      row :weakness2
    end
  end

end