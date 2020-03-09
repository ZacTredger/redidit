# Module overrides methods in collections of votes associated with a votable.
# Include in a block passed to the `has_many(:votes)` call in the votable
module VoteCollectionMethods
  # A vote shouldn't be created if the voter has already voted on this votable
  def build(vote_attributes)
    previously_cast_vote = find_by(user_id: vote_attributes[:user_id])
    return super(vote_attributes) unless previously_cast_vote

    up = vote_attributes[:up] == 'true'
    return ErrorVote.new(up) if previously_cast_vote.up == up

    previously_cast_vote.up = up
    previously_cast_vote
  end

  # Implements an interface to explain why an attempt to vote has failed
  class ErrorVote
    def initialize(upvoted)
      @up_or_down_voted = "#{upvoted ? 'up' : 'down'}voted"
    end

    def save
      false
    end

    def error_text
      "You already #{up_or_down_voted} this!"
    end

    private

    attr_reader :up_or_down_voted
  end
end
