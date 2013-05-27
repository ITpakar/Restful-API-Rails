module Api
  module V1
    class VersionsController < Api::V1::BaseController
      skip_before_filter :validate_authentication_token

      def index
        json = {
          version: 1.0,
          author: {
            api: ["Jedford Seculles"],
            ios: ["Nikki Fernandez", "Andy Lim"],
            company: ["SourcePad Inc."]
          },
          vendor: "Quotiful",
          alive: true,
          uptime: Time.now.to_i,
          success: true
        }
        render json: json, status: 200
      end
    end
  end
end