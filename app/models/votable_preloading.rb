# Overrides methods in a votable model, i.e. the Post or Comment classes
# Extend the votable class with this module AND
# Include in a block passed to a `has_many(<votable>)` call in a class body
module VotablePreloading
  # Passing a user to the vote_from argument will preload that user's vote
  #  only. Use to preload a viewer's vote to render appropriate vote controls.
  # The vote_from option cannot be used on multiple models in the same query
  #  eg includes(comments: { vote_from: user }, vote_from: user) does not work
  def includes(*args, vote_from: nil, **k_args)
    return super(*args, **k_args) unless (voter_id = vote_from&.id)

    # `votes: {}` is a hack to avoid passing an argument after a keyword-arg
    #  (which is not permitted). It behaves as if `:votes` was passed last.
    eager_load(*args, **k_args, votes: {})
      .joins("AND votes.user_id = #{voter_id}")
  end
end
