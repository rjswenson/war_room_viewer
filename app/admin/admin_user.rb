ActiveAdmin.register AdminUser do
  menu parent: 'Admin'

  permit_params :email,
    :password,
    :password_confirmation,
    :import_notification_level,
    :time_zone,
    :send_all_order_emails,
    :role_id

  filter :email, as: :string

  controller do
    def current_ability
      @current_ability ||= ::Ability.new(current_admin_user)
    end

    def scoped_collection
      AdminUser.includes(:role).accessible_by(current_ability)
    end
  end

  index do
    selectable_column
    column :email
    column :import_notification_level do |a|
      status_tag (a.import_notification_level.titleize)
    end
    column :send_all_order_emails do |a|
      status_tag (a.send_all_order_emails.to_s)
    end
    column :time_zone
    column :role do |a|
      a.role.name if a.role
    end
    column :current_sign_in_at, local_time(:current_sign_in_at)
    column :last_sign_in_at, local_time(:last_sign_in_at)
    column :sign_in_count
    actions
  end

  show :title => :id do
    attributes_table do
      row :email
      row :import_notification_level
      row :send_all_order_emails do
        admin_user.send_all_order_emails.to_s
      end
      row :time_zone
      row :role do
        admin_user.role.name
      end
      row :current_sign_in_at do
        local_time(:current_sign_in_at).call(admin_user)
      end
      row :last_sign_in_at do
        local_time(:last_sign_in_at).call(admin_user)
      end
      row :sign_in_count
    end
  end

  form do |f|
    f.inputs "Admin Details" do
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :import_notification_level,
        :as => :select,
        :collection => ['none', 'errors', 'errors + warnings', 'all'],
        :hint => "Use this to select the how often you'd like to be emailed about imports"
      f.input :send_all_order_emails,
        :as => :boolean,
        :hint => "Check this if you want to receive all order related emails sent to dealers and reps"
      f.input :time_zone,
        :as => :time_zone
      f.input :role_id, :label => 'Role',
        :as => :select,
        :collection => Role.all.map {|r| [r.name, r.id]},
        :include_blank => false
    end
    f.actions
  end
end