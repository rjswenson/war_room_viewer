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
    column :key do |game|
      link_to game.key, admin_game_path(game)
    end
    column :name
    column :year
    column :tags
    actions
  end

  show title: proc{|game| "#{game.name} - #{game.key}"} do
    attributes_table do
      row :key
      row :name
      row :year
      row :tags
    end

    panel 'Units' do
      ol do
        game.units.where(:_type => "Unit::Rank").order_by(:pop_cost => 'asc').each do |rank_unit|
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