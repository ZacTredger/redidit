# Include module in post and comment models
module Votable 
  # Ensures no votes are loaded for guests so they always see neutral controls
  def viewers_vote
    @viewers_vote ||= votes.loaded? ? votes.first : nil
  end
end
