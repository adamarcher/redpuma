class SessionsController < ApplicationController

  def new
    @title = "Sign in"
  end

  def create
    user = User.authenticate(params[:session][:email],
			     params[:session][:password])
    if user.nil?
      flash.now[:error] = "Invalid email or password."
      @title = "Sign in"
      render :new
    else
      sign_in user
      redirect_to user
    end

  end  # def create

  def destroy
    sign_out
    redirect_to root_path
  end

end
