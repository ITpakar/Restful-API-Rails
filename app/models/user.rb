# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  authentication_token   :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  full_name              :string(255)
#  profile_picture_uid    :string(255)
#  profile_picture_name   :string(255)
#  auto_accept            :boolean          default(TRUE)
#  facebook_id            :integer
#  bio                    :text
#  website                :string(255)      default("")
#  follows_count          :integer          default(0)
#  followed_by_count      :integer          default(0)
#  posts_count            :integer          default(0)
#

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :token_authenticatable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation,
                  :full_name, :auto_accept, :facebook_id, :bio,
                  :website, :follows_count, :followed_by_count, :posts_count

  before_save :ensure_authentication_token

  image_accessor :profile_picture

  def to_builder
    bool_errors = self.errors.present?
    Jbuilder.new do |json|
      json.data do |data|
        data.user do |user|
          user.(self, :full_name, :bio, :website, :follows_count, :followed_by_count, :posts_count, :email, :authentication_token)
          if self.profile_picture.present?
            user.profile_picture_url = self.profile_picture.jpg.url
          else
            user.profile_picture_url = ''
          end
        end
        
        if bool_errors
          data.errors self.errors
        end
      end
      json.success !bool_errors
      json.status (bool_errors ? 422 : 201)
    end
  end
end
