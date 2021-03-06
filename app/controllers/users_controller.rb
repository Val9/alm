class UsersController < ApplicationController

  respond_to :html
  
  def show
    load_user
    @doc = { :title => "Getting Started", :text => IO.read(Rails.root.join("docs/Home.md")) }
  end
  
  def index
    redirect_to root_path
  end
  
  def edit
    load_user
  end

  def update_password
    load_user
    if @user.update_with_password(params[:user])
      # Sign in the user by passing validation in case his password changed
      sign_in @user, :bypass => true
      redirect_to root_path
    else
      render "edit"
    end
  end
  
  protected
  def load_user
    if user_signed_in?
      @user = current_user
    else
      raise CanCan::AccessDenied.new("Please sign in first.", :read, User)
    end
  end
end