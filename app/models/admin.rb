# == Schema Information
#
# Table name: admins
#
#  id                 :integer          not null, primary key
#  email              :string(255)      default(""), not null
#  encrypted_password :string(255)      default(""), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class Admin < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :registerable, :confirmable,
  # :rememberable, :trackable, :validatable, :recoverable,
  # :lockable and :omniauthable
  devise :database_authenticatable, :timeoutable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation
end
