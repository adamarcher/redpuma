class MicropostsController < ApplicationController
  before_filter :authenticate, :only => [:create, :destroy]
  before_filter :authorized_user, :only => :destroy

  def create
    @micropost = current_user.microposts.build(params[:micropost])
    @micropost.score = set_score

    if @micropost.save

      # NOT USED -- I couldn't get the total_score to save in the DB!
      # update_user_total_score

      current_scoreboard = create_scoreboard()
      flash[:success] = current_scoreboard.join("<br/>").html_safe
      redirect_to root_path
    else
      @feed_items = []
      render 'pages/home'
    end
  end

  def destroy
    @micropost.destroy
    redirect_back_or root_path
  end

  private

    def authorized_user
      @micropost = Micropost.find(params[:id])
      redirect_to root_path unless current_user?(@micropost.user)
    end

    # NOT USED -- I couldn't get the total_score to save in the DB!
    def update_user_total_score

      old_total_score = @micropost.user.total_score
      old_name = @micropost.user.name
      puts("D1 old_total_score #{old_total_score}")
      puts("D1 old_name #{old_name}")
      puts("D1 micropost.score #{@micropost.score}")

      if @micropost.user.total_score
        new_total_score = @micropost.user.total_score + @micropost.score
        @micropost.user.total_score = new_total_score
        @micropost.user.name = "Hallie Berry"
        puts("D2 users total_score is not nil and is #{@micropost.user.total_score}")
      else
        @micropost.user.total_score = @micropost.score
        puts("D2 users total_score IS nil")
      end

      if @micropost.user.save
        puts("D3 user save SUCCESSFUL")
      else
        puts("D3 user save NOT successful")
      end

      new_total_score = @micropost.user.total_score
      puts("D4 new_total_score #{new_total_score}")
      puts("D4 new_name #{@micropost.user.name}")
      puts("----------------------------------------------------")

    end

    def create_scoreboard

      scoreboard = Array.new
      @users = Array.new
      scoreboard << create_first_scoreboard_line

      # make last_7_days_score in the users table an autogenerated column

      # Copy all of the current_user's followING users
      @users = @micropost.user.following.dup

      blank = ""
      scrbrd = "SCOREBOARD FOR LAST 7 DAYS:"
      dot = "."
      line = "---------------------------------------------"

      # sort all followING users by last_7_days_score column in users table
      @users.each do |user|
        total_score = 0
        user.total_score = 0 # Fixing bug where David's score is borking the site
	user.microposts.each do |post|
	  if post.created_at >= 1.week.ago
	    total_score = total_score + post.score
            user.total_score = total_score
	  end
        end
      end

      # Add the current user to the array of all users to be printed
      # in the scoreboard
      total_score = 0
      three_day_score = 0
      twenty_four_hour_score = 0
      complete_score = 0
      @micropost.user.microposts.each do |post|

	complete_score = complete_score + post.score

	if post.created_at >= 1.week.ago
	  total_score = total_score + post.score
	end
	if post.created_at >= 3.day.ago
	  three_day_score = three_day_score + post.score
	end
	if post.created_at >= 24.hour.ago
	  twenty_four_hour_score = twenty_four_hour_score + post.score
	end
      end
      @micropost.user.total_score = total_score
      @users << @micropost.user.dup

      # In the future, just change 100000 to the LNW they give me at sign-up
      total_current_net_worth = 100000 + @micropost.user.total_score 
      total_current_net_worth = 100000 + complete_score 
      total_current_net_worth_commas = number_with_delimiter(total_current_net_worth)

      projected_net_worth_at_retirement = (1.08**30)*total_current_net_worth
      projected_net_worth_at_retirement_commas = number_with_delimiter(projected_net_worth_at_retirement.to_i)

      retire_net_worth_diff = (1.08**30)*@micropost.score

      scoreboard << blank << line << blank
      scoreboard << "Projected Net Worth at Retirement: $#{projected_net_worth_at_retirement_commas} (+ $#{retire_net_worth_diff.to_i})"
      scoreboard << "Total Current Net Worth: $#{total_current_net_worth_commas}"
      scoreboard << blank << line << blank
      scoreboard << "Total Savings in last 24 hours: $#{twenty_four_hour_score}"
      scoreboard << "Total Savings in last 3 days: $#{three_day_score}"
      scoreboard << blank << line << blank
      scoreboard << scrbrd << dot << dot << dot

      # display the users in sorted order
      n = 1
      @users.sort! { |x, y| y["total_score"] <=> x["total_score"] }
      @users.each do |user|
        scoreboard << "#{n}. #{user.name}: $#{user.total_score}"
	n = n + 1
      end

      return scoreboard

    end

    def create_first_scoreboard_line

      case rand(7)
      when 0
        return "Nice work! You\'re really moving up!"
      when 1
        return "Way to go! Every action counts!"
      when 2
        return "Great job! You\'re really cranking now!"
      when 3
        return "Good stuff! Savin\' it is the same as earnin\' it!"
      when 4
        return "Keep up the great work! You're savin\' savin\' savin\'!"
      when 5
        return "You are a scoring machine! Way to go!"
      when 6
        return "Woo hoo! No stopping you now!"
      else
        return "Niaiaiaiaice work! Keep it up and you'll die very rich!"
      end

    end

    def set_score

      case 

      # CLOTHES

      when @micropost.description =~ /CLOTHES.+washed/
        return 10 
      when @micropost.description =~ /CLOTHES.+made/
        return 30 
      when @micropost.description =~ /CLOTHES.+discount.retailer/
        return 50 
      when @micropost.description =~ /CLOTHES.+used.+clothing.+store/
        return 50 
      when @micropost.description =~ /CLOTHES.+repaired/
        return 50 
      when @micropost.description =~ /CLOTHES.+traded/
        return 50 
      when @micropost.description =~ /CLOTHES.+borrowed/
        return 300

      # DRINK

      when @micropost.description =~ /DRINK.+water/
        return 3
      when @micropost.description =~ /DRINK.+coffee/
        return 3
      when @micropost.description =~ /DRINK.+got.+free.+drinks/
        return 20
      when @micropost.description =~ /DRINK.+game/
        return 25

      # FINANCE

      when @micropost.description =~ /FINANCE.+donated/
        return 20
      when @micropost.description =~ /FINANCE.+savings/
        return 30
      when @micropost.description =~ /FINANCE.+debt/
        return 50
      when @micropost.description =~ /FINANCE.+retirement/
        return 50

      # FOOD

      when @micropost.description =~ /FOOD.+permission/
        return 5
      when @micropost.description =~ /FOOD.+breakfast/
        return 5
      when @micropost.description =~ /FOOD.+lunch/
        return 10
      when @micropost.description =~ /FOOD.+dinner/
        return 20
      when @micropost.description =~ /FOOD.+brunch/
        return 25
      when @micropost.description =~ /FOOD.+parents/
        return 25
      when @micropost.description =~ /FOOD.+discount.grocery/
        return 50

      # HOME

      when @micropost.description =~ /HOME.+internet/
        return 20
      when @micropost.description =~ /HOME.+Netflix/
        return 20
      when @micropost.description =~ /HOME.+utility/
        return 20
      when @micropost.description =~ /HOME.+roommate/
        return 500
      when @micropost.description =~ /HOME.+family.+FREE/
        return 1000
      when @micropost.description =~ /HOME.+family/
        return 700

      # OTHER

      when @micropost.description =~ /OTHER.+matinnee/
        return 2
      when @micropost.description =~ /OTHER.+Facebook/
        return 10
      when @micropost.description =~ /OTHER.+beauty/
        return 30
      when @micropost.description =~ /OTHER.+baby/
        return 80

      # SHOP

      when @micropost.description =~ /SHOP.+generic/
        return 3
      when @micropost.description =~ /SHOP.+coupon/
        return 5
      when @micropost.description =~ /SHOP.+Costco/
        return 10
      when @micropost.description =~ /SHOP.+library/
        return 10
      when @micropost.description =~ /SHOP.+online/
        return 20
      when @micropost.description =~ /SHOP.+returned/
        return 25
      when @micropost.description =~ /SHOP.+sold/
        return 25
      when @micropost.description =~ /SHOP.+Groupon/
        return 25
      when @micropost.description =~ /SHOP.+regifted/
        return 50
      when @micropost.description =~ /SHOP.+salesperson/
        return 50

      # TRAVEL

      when @micropost.description =~ /TRAVEL.+carpooled/
        return 3
      when @micropost.description =~ /TRAVEL.+walked/
        return 3
      when @micropost.description =~ /TRAVEL.+public/
        return 10
      when @micropost.description =~ /TRAVEL.+parking/
        return 10
      when @micropost.description =~ /TRAVEL.+ZipCar/
        return 20
      when @micropost.description =~ /TRAVEL.+airport/
        return 30
      when @micropost.description =~ /TRAVEL.+hotel/
        return 100
      when @micropost.description =~ /TRAVEL.+miles/
        return 200

      else
        flash[:error] = "Your points were given. However, please email \
			admin@redpuma.com and let them know that you \ 
			recieved error 101 when saving your action. Thank \
			you!"
        return 20
      end
    end

    def number_with_delimiter(number, delimiter=",", separator=".")
      begin
        parts = number.to_s.split('.')
	parts[0].gsub!(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{delimiter}")
	parts.join separator
      rescue
        number
      end
    end

end
