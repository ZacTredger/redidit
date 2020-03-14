# Use to construct voting buttons on posts and comments
module VotableHelper
  def voting_controls_for(votable, view)
    VotingControls.for(votable, view)
  end

  # Ancestor and constructor class
  class VotingControls
    class << self
      # Constructor
      def for(votable, view)
        return NoControls.new(view) if votable.redacted?

        subclass =
          if (vote = votable.viewers_vote)
            vote.up ? StartingUp : StartingDown
          else StartingNeutral
          end
        subclass.new(votable, view)
      end
    end

    def initialize(view)
      @view = view
    end

    private

    attr_reader :view
    delegate :safe_join, :content_tag, :button_to, :render, to: :view
  end

  # Display no controls for redacted comments
  class NoControls < VotingControls
    def html
      content_tag(:div, class: 'no-controls') {}
    end
  end

  # Parent class of actual voting-control generators
  class ActualControls < VotingControls
    def initialize(votable, view)
      @votable = votable
      @votable_identifier = "-#{votable.class.to_s.downcase}-#{votable.id}"
      super(view)
    end

    def html
      content_tag :div, class: 'vote-controls' do
        safe_join [button_to(model, upward_button) { render upward_arrow },
                   content_tag(:p, votable.karma, class: 'karma'),
                   button_to(model, downward_button) { render downward_arrow }]
      end
    end

    def upward_arrow
      arrow
    end

    def downward_arrow
      arrow(direction: 'down')
    end

    private

    attr_reader :votable, :args_for, :model, :votable_identifier

    # Default colour is neutral-grey
    def arrow(direction: 'up', colour: '#878a8c')
      {
        partial: 'svg/vote_arrow',
        formats: [:svg],
        locals: { direction: direction, colour: colour }
      }
    end

    def id_starting(id_start)
      id_start + votable_identifier
    end
  end

  # Supplies variations for controls when user has not yet voted on the votable
  class StartingNeutral < ActualControls
    def initialize(votable, view)
      @model = [votable, :votes]
      super
    end

    def upward_button
      { id: id_starting('upvote'), params: { vote: { up: true } } }
    end

    def downward_button
      { id: id_starting('downvote'), params: { vote: { up: false } } }
    end
  end

  # Supplies variations for controls when user has already upvoted the votable
  class StartingUp < ActualControls
    def initialize(votable, view)
      @model = votable.viewers_vote
      super
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
  class StartingDown < ActualControls
    def initialize(votable, view)
      @model = votable.viewers_vote
      super
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
