class ApplicationController < ActionController::Base
  protect_from_forgery

  def after_sign_out_path_for(resource_or_scope)
    case resource_or_scope
    when :admin, Admin
      new_admin_session_path
    else
      super
    end
  end
end
