# Include module in post and comment models
module Votable 
  # Ensures no votes are loaded for guests so they always see neutral controls
  def viewers_vote
    @viewers_vote ||= votes.loaded? ? votes.first : nil
  end

  private
  
  def add_creators_upvote
    votes.create user_id: user.id, up: true
  end
end
