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

  show title: proc{|species| "#{species.name} - #{species.key}"} do
    attributes_table do
      column :key do |species|
      link_to species.key, admin_species_path(species)
    end
      row :name
      row :home_planet
    end

    panel 'Units' do
      ol do
        species.units.where(:_type => "Unit::Rank").order_by(:pop_cost => 'asc').each do |rank_unit|
          li do
            h3 b rank_unit.name
            attributes_table_for rank_unit do
              row :name
              row :key
            end
          end
        end
      end
    end
  end
end
