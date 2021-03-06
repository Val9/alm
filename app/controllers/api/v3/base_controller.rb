class Api::V3::BaseController < ActionController::Base 
   
  respond_to :json, :xml, :only => [ :index, :show ]
  
  before_filter :default_format_json, :after_token_authentication 

  def default_format_json
    request.format = :json if request.format.html?
  end

  def after_token_authentication
    if params[:api_key].present?
      # @user = User.find_by_authentication_token(params[:api_key])
      # sign_in @user if @user
    else
      @error = "Missing API key."
      ErrorMessage.create(:exception => "", :class_name => "Net::HTTPUnauthorized",
                          :message => @error, 
                          :status => 401)
      render "401", :status => 401
    end
  end
end