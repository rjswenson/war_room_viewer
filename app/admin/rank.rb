ActiveAdmin.register Unit::Rank, as: 'Ranks' do
  menu parent: 'Unit'
  actions :index, :edit, :create, :update, :new, :show, :destroy
  #:duplicate, :preview, :publish

  # config.sort_order = "name_desc"

  filter :key, as: :string
  # filter :game, as: :select, collection: Proc.new {Game.distinct(:key)}
  # filter :species, as: :select, collection: Proc.new {Species.distinct(:key)}
  controller do
    def permitted_params
      params.require(:unit_rank).permit!
    end

    def scoped_collection
      Unit::Rank
    end
  end

  index do
    selectable_column
    column "Portrait" do |rank|
      if rank.images.present?
        image_tag image_path_or_missing(rank.images['P'][0], 'icon')
        # binding.pry
      end
    end
    column :key do |rank|
      link_to rank.key, admin_rank_path(rank)
    end
    column :name
    column :pop_cost
    column :hitpoints
    column :shield
    column :build_time
    column :species, sortable: :species do |unit|
      if unit.species.present?
        link_to unit.species.key, admin_species_path(unit.species.id)
      end
    end
    column :armor, sortable: :armor do |unit|
      if unit.armor.present?
        link_to unit.armor.key, admin_armor_path(unit.armor.id)
      end
    end
    column :game, sortable: :game do |unit|
      if unit.game.present?
        link_to unit.game.key, admin_game_path(unit.game.id)
      end
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
