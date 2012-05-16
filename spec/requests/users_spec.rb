require 'spec_helper'

describe "Users" do

  describe "signup" do

    describe "failure" do

      it "should not create a new user" do

        lambda do
          visit signup_path
          fill_in "Full Name",		:with => ""
          fill_in "Email",		:with => ""
          fill_in "Password",		:with => ""
          fill_in "Confirm Password",	:with => ""
	  click_button
	  response.should render_template('users/new')
	  response.should have_selector("div#error_explanation")
	end.should_not change(User, :count)

      end

    end # describe "failure" do


    describe "success" do

      it "should create a new user" do

        lambda do
          visit signup_path
          fill_in "Full Name",		:with => "Joe Example"
          fill_in "Email",		:with => "testuser@example.com"
          fill_in "Password",		:with => "testuser"
          fill_in "Confirm Password",	:with => "testuser"
	  click_button
	  response.should have_selector("div.flash.success",
					:content => "Welcome")
	  response.should render_template('home')
	end.should change(User, :count).by(1)

      end

    end # describe "success" do

  end # describe "signup" do


  describe "sign in/out" do

    describe "failure" do
      it "should not sign a user in" do
        visit signin_path
        fill_in :email, 	:with => ""
	fill_in :password,	:with => ""
	click_button
	response.should have_selector("div.flash.error", :content => "Invalid")
      end
    end

    describe "success" do
      it "should sign a user in and out" do
	@user = Factory(:user)
        integration_sign_in(@user)
        controller.should be_signed_in 
        click_link "Sign out"
        controller.should_not be_signed_in
      end
    end

  end  # describe "sign in/out" do

end # describe "Users" do
