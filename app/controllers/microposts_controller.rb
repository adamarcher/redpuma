class MicropostsController < ApplicationController
  before_filter :authenticate, :only => [:create, :destroy]
  before_filter :authorized_user, :only => :destroy

  def create
    @micropost = current_user.microposts.build(params[:micropost])
    @micropost.score = set_score

    if @micropost.save
      # TODO: This is a hack, must fix.
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

    # Hack. TODO: Must fix this
    def create_scoreboard

      scoreboard = Array.new
      current_amt_saved = "Total Money Saved so far due to game: $2,345"
      line = "---------------------------------------------"
      intro = "Nice work! You\'re really moving up!"
      blank = ""
      scrbrd = "SCOREBOARD:"
      dot = "."
      line1 = "4. Adam:    65 points"
      line2 = "5. Jesse:   54 points"
      line3 = "6. Lillian: 43 points"

      scoreboard << intro << blank << scrbrd << dot \
			 << dot   << line1 << line2  << line3 \
			 << dot   << dot   << blank  << line \
			 << blank << current_amt_saved
      return scoreboard

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
