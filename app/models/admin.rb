class Admin < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :registerable, :confirmable,
  # :rememberable, :trackable, :validatable, :recoverable,
  # :lockable and :omniauthable
  devise :database_authenticatable, :timeoutable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation
end
