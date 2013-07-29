module Api
  module V1
    module Users
      class RelationshipsController < Api::V1::UsersController

        before_filter :validates_difference_of_users, only: [:create]
        
        def index
          as_follower = Relationship.find_by_user_id_and_follower_id(instance_user.id, current_user.id)
          as_followed_by = Relationship.find_by_user_id_and_follower_id(current_user.id, instance_user.id)

          json = relationship_response(as_follower, as_followed_by)

          render json: json, status: 200
        end

        def create
          as_follower = Relationship.find_or_initialize_by_user_id_and_follower_id(user_id: instance_user.id, follower_id: current_user.id)
          as_followed_by = Relationship.find_or_initialize_by_user_id_and_follower_id(user_id: current_user.id, follower_id: instance_user.id)

          if "follow".eql?(params[:status])
            as_follower.follow!
          elsif "approve".eql?(params[:status])
            as_followed_by.approve!
          elsif "block".eql?(params[:status])
            as_followed_by.block!
          elsif %(deny unblock).include?(params[:status])
            as_followed_by.deny!
          elsif "unfollow".eql?(params[:status])
            as_follower.unfollow!
          end

          as_follower = as_follower.new_record? ? nil : as_follower
          as_followed_by = as_followed_by.new_record? ? nil : as_followed_by

          json = relationship_response(as_follower, as_followed_by)

          render json: json, status: 200
        end

        protected

          def relationship_response(as_follower, as_followed_by)
            {
              data: {
                outgoing_status: as_follower.try(:status),
                incoming_status: as_followed_by.try(:status),
                following_me: (as_followed_by.present? && as_followed_by.status.eql?('approved')),
                am_follower: (as_follower.present? && as_follower.status.eql?('approved')),
                following_me_date: as_followed_by.try(:created_at).to_i,
                am_follower_date: as_follower.try(:created_at).to_i
              },
              success: true
            }.to_json
          end

          def ensure_params_id_exist
            return unless params[:user_id].blank?
            render json: { success: false, message: "Missing user_id parameter" }, status: 200
          end

          def check_existence_of_user
            return if User.exists?(id: params[:user_id])
            render json: { success: false, message: "User not found" }, status: 200
          end

          def instance_user
            @instance_user ||= User.find(params[:user_id])
          end

          def validates_difference_of_users
            return if instance_user.id != current_user.id
            render json: { success: false, message: "Invalid request for following yourself" }, status: 200
          end
      end
    end
  end
end