ActiveAdmin.register ::Unit::Rank, as: 'Rank Units' do
	menu parent: 'Unit'
  actions :index, :edit, :create, :update, :new, :duplicate, :preview, :publish, :show, :destroy

  config.sort_order = 'priority_desc'
  config.filters = false
end
