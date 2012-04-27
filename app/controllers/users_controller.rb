class UsersController < ApplicationController

  def show
    @user = User.find(params[:id])
    @title = @user.name
  end

  def new
    @user = User.new
    @title = "Sign up"
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      # Handle a successful user DB save
      flash[:success] = "Welcome to RedPuma!"
      redirect_to @user
    else
      # Not a successful user DB save!
      @title = "Sign up"
      render 'new'
    end

  end # def create

end
