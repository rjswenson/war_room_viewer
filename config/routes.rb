Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  devise_for :admin_users, ActiveAdmin::Devise.config

  root to: "home#index"

  devise_for :users, :controllers => {:sessions => :sessions, :passwords => :passwords}

  devise_scope :user do
    post "sessions/validate"
    post "sessions/destroy" # TODO: should this be delete?
    post "users/password" => "passwords#update"
    post "users/:id" => "users#update"
  end

  resources :users

  resources :armors
  resources :abilities
  resources :units
end
