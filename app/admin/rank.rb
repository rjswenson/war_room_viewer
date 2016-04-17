ActiveAdmin.register ::Unit::Rank, as: 'Ranks' do
  menu parent: 'Unit'
  actions :index, :edit, :create, :update, :new, :show, :destroy
  #:duplicate, :preview, :publish
  config.filters = false

  def permitted_params
    params.require(:unit_rank).permit!
  end

  index do
    selectable_column
    column :name
    column :key
    column :size
    column :resource_1
    column :resource_2
    column :resource_3
    column :pop_cost
    column :hitpoints
    column :shield
    column :armor_value
    column :g_attack
    column :a_attack
    column :sight
    column :build_time
    column :species do |unit|
      unit.species.try(:key)
    end
    column :armor do |unit|
      unit.armor.try(:key)
    end
    column :game do |unit|
      unit.game.try(:key)
    end
    actions
  end

  show do
    attributes_table do
      row :name
      row :key
      row :size
      row :resource_1
      row :resource_2
      row :resource_3
      row :pop_cost
      row :hitpoints
      row :shield
      row :g_attack
      row :a_attack
      row :sight
    end

    panel 'Armor' do
      if ( armor = ranks.armor ) && armor.present?
        table_for armor do
          column :name
          column :key
          column :type
        end
      end
    end

    panel 'Species' do
      if ( species = ranks.species ) && species.present?
        table_for species do
          column :name
          column :key
          column :home_planet
          column :description
        end
      end
    end

    panel 'Game' do
      if ( game = ranks.game ) && game.present?
        table_for game do
          column :name
          column :key
          column :year
        end
      end
    end
  end
end
