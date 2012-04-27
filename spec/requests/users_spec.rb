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
          fill_in "Email",		:with => "user@example.com"
          fill_in "Password",		:with => "examplepassword"
          fill_in "Confirm Password",	:with => "examplepassword"
	  click_button
	  response.should have_selector("div.flash.success",
					:content => "Welcome")
	  response.should render_template('users/show')
	end.should change(User, :count).by(1)

      end

    end # describe "success" do

  end # describe "signup" do

end # describe "Users" do
