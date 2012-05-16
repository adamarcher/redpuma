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
      # TODO make this an actual real amount
      # current_amt_saved = "Total Money Saved so far due to game: $2,345"
      current_amt_saved = ""
      scrbrd = "SCOREBOARD:"
      dot = "."
      line = "---------------------------------------------"

      scoreboard << blank << scrbrd << dot << dot << dot

      # sort all followING users by last_7_days_score column in users table
      @users.each do |user|
        total_score = 0
	user.microposts.each do |post|
	  total_score = total_score + post.score
          user.total_score = total_score
        end
      end

      # Add the current user to the array of all users to be printed
      # in the scoreboard
      total_score = 0
      @micropost.user.microposts.each do |post|
	total_score = total_score + post.score
      end
      @micropost.user.total_score = total_score
      @users << @micropost.user.dup

      # display the users in sorted order
      n = 1
      @users.sort! { |x, y| x["total_score"] <=> y["total_score"] }
      @users.each do |user|
        scoreboard << "#{n}. #{user.name}: #{user.total_score} points"
	n = n + 1
      end

      scoreboard << dot << dot << blank << line << blank << current_amt_saved

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
      when @micropost.description =~ /beverage/
        return 3
      when @micropost.description =~ /breakfast|carpooled/
        return 5
      when @micropost.description =~ /public/
        return 6
      when @micropost.description =~ /walked/
        return 8
      when @micropost.description =~ /lunch|free/
        return 10
      when @micropost.description =~ /dinner|donated|utility|spend|Facebook|posted/
        return 20
      when @micropost.description =~ /points/
        return 25
      when @micropost.description =~ /deposited/
        return 30
      else
        flash[:error] = "Your points were given. However, please email \
			admin@redpuma.com and let them know that you \ 
			recieved error 101 when saving your action. Thank \
			you!"
        return 20
      end
    end

end
