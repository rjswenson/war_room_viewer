module ClassMethods
  Devise::Models.config(self, :email_regexp, :password_length)
end

class User
  include Mongoid::Document
  include Mongoid::Paranoia

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, #:registerable,
         :recoverable, :rememberable, :trackable

  ## DEVISE FIELDS
  ## Database authenticatable
  field :email,              :type => String, :default => ""
  field :encrypted_password, :type => String, :default => ""

  ## Recoverable
  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Trackable
  field :sign_in_count,      :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip,    :type => String
  ## END DEVISE FIELDS

  extend ClassMethods

  def self.authentication_keys
    [:username]
  end

  field :username, :type => String
  field :email, :type => String
  field :remember_token
  field :first_name, :type => String
  field :last_name, :type => String
  field :login_count
  field :is_disabled, :type => Boolean, :default => false
end
