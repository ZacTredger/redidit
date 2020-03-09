# Use to construct voting buttons on posts and comments
module VotableHelper
  def voting_controls_for(votable)
    VotingControls.for(votable)
  end

  # Parent class
  class VotingControls
    class << self
      # Constructor
      def for(votable)
        subclass =
          if (vote = votable.viewers_vote)
            vote.up ? StartingUp : StartingDown
          else StartingNeutral
          end
        subclass.new(votable)
      end
    end

    attr_reader :model, :votable_identifier

    def initialize(votable)
      @votable = votable
      @votable_identifier = "-#{votable.class.to_s.downcase}-#{votable.id}"
    end

    def karma
      votable.karma
    end

    def upward_arrow
      arrow
    end

    def downward_arrow
      arrow(direction: 'down')
    end

    private

    attr_reader :votable, :args_for

    # Default colour is neutral-grey
    def arrow(direction: 'up', colour: '#878a8c')
      { partial: 'svg/vote_arrow',
        formats: [:svg],
        locals: { direction: direction, colour: colour}
      }
    end

    def id_starting(id_start)
      id_start + votable_identifier
    end
  end

  # Supplies variations for controls when user has not yet voted on the votable
  class StartingNeutral < VotingControls
    def initialize(votable)
      @model = [votable, :votes]
      super(votable)
    end

    def upward_button
      { id: id_starting('upvote'), params: { vote: { up: true } } }
    end

    def downward_button
      { id: id_starting('downvote'), params: { vote: { up: false } } }
    end
  end

  # Supplies variations for controls when user has already upvoted the votable
  class StartingUp < VotingControls
    def initialize(votable)
      @model = votable.viewers_vote
      super(votable)
    end

    def upward_button
      { id: id_starting('cancel-upvote'), method: :delete }
    end

    def upward_arrow
      arrow colour: '#ff4500'
    end

    def downward_button
      { id: id_starting('reverse-upvote'), params: { vote: { up: true } },
        method: :patch }
    end
  end

  # Supplies variations for controls when user has already downvoted the votable
  class StartingDown < VotingControls
    def initialize(votable)
      @model = votable.viewers_vote
      super(votable)
    end

    def upward_button
      { id: id_starting('reverse-downvote'), params: { vote: { up: false } },
        method: :patch }
    end

    def downward_button
      { id: id_starting('cancel-downvote'), method: :delete }
    end

    def downward_arrow
      arrow direction: 'down', colour: '#0079d3'
    end
  end
end
