require 'test_helper'

class VotesTest < ActionDispatch::IntegrationTest
  class VotableDelegator < SimpleDelegator
    delegate :to_s, to: :to_sym
    attr_reader :to_sym, :create_vote_path
    def initialize(votable)
      @to_sym = votable
      @create_vote_path = "#{votable}_votes_path".to_sym
    end
  end

  class CommentDelegator < VotableDelegator; end

  class PostDelegator < VotableDelegator
    def post
      __getobj__
    end
  end

  Direction = Struct.new(:to_sym, :opposite, :effect, :value) do
    delegate :to_s, to: :to_sym
    def vote(opp = nil)
      { opp ? opposite : to_sym => 1 }
    end
  end

  VOTABLE_DELEGATORS = [
    PostDelegator.new(:post),
    CommentDelegator.new(:comment)
  ].freeze
  DIRECTIONS = [
    Direction.new(:up, :down, 'increases', 1),
    Direction.new(:down, :up, 'decreases', -1)
  ].freeze

  SETUP = begin
    VOTABLE_DELEGATORS.each do |delegator|
      DIRECTIONS.each do |direction|
        define_method "test_#{direction}voting_a_#{delegator}"\
                      "_#{direction.effect}_its_karma" do
          log_in
          get page_showing votable(delegator)
          assert_select "button##{direction}vote-#{votable}-#{votable.id}"
          assert_difference('votable.reload.karma', direction.value) do
            cast_vote(direction)
          end
        end

        define_method "test_withdrawing_#{direction}vote_resets_#{delegator}"\
                      '_karma' do
          vote = votable(delegator, direction.vote).votes.last
          log_in as: vote.user
          get page_showing votable
          assert_select "#cancel-#{direction}vote-#{votable}-#{votable.id}"
          assert_difference 'votable.reload.karma', -1 * direction.value do
            delete vote_path(vote)
          end
        end

        define_method "test_cannot_withdraw_others_users_#{delegator}"\
                      "_#{direction}vote" do
          vote = votable(delegator, direction.vote).votes.last
          log_in
          get page_showing votable
          assert_select "#cancel-#{direction}vote-#{votable}-#{votable.id}",
                        false
          assert_no_difference 'votable.reload.karma' do
            delete vote_path(vote)
          end
          assert_redirect_with_bad_flash
        end

        define_method "test_guests_cannot_#{direction}vote_#{delegator}"\
                      '_until_logged_in' do
          votable(delegator, direction.vote)
          get page_showing votable(delegator)
          assert_select "button##{direction}vote-#{votable}-#{votable.id}"
          assert_no_difference 'votable.reload.karma' do
            cast_vote(direction)
          end
          assert_redirected_to login_path
          # follow_redirect!
          # assert_difference 'votable.reload.karma', opts[:value] do
          #   log_in
          #   assert_redirected_to page_showing votable
          # end
        end

        define_method "test_users_can_reverse_their_#{direction}vote_on_a"\
                      "#{delegator}" do
          vote = votable(delegator, direction.vote).votes.last
          log_in as: vote.user
          get page_showing votable
          assert_select "#reverse-#{direction}vote-#{votable}-#{votable.id}"
          assert_difference 'votable.reload.karma', -2 * direction.value do
            # No need to send params to vote#update; it figures it out
            patch vote_path(vote)
          end
        end

        define_method "test_users_may_only_#{direction}vote_#{delegator}s"\
                      '_once' do
          vote = votable(delegator, direction.vote).votes.last
          log_in as: vote.user
          get page_showing votable
          assert_select "button##{direction}vote-#{votable}-#{votable.id}",
                        false
          assert_no_difference('votable.reload.karma') { cast_vote(direction) }
          assert_redirect_with_bad_flash
        end

        define_method "test_#{direction}voting_a_#{direction.opposite}voted"\
                      "_#{delegator}_changes_#{direction.opposite}vote_to"\
                      "_#{direction}vote" do
          vote = votable(delegator, direction.vote(:opposite)).votes.last
          log_in as: vote.user
          get page_showing votable
          assert_difference 'votable.reload.karma', 2 * direction.value do
            cast_vote direction
          end
        end
      end
    end
  end

  private

  # At construction, pass delegator & (if needed) :upvote & :downvote counts
  def votable(delegator = nil, up: 0, down: 0)
    return @votable if @votable

    delegator.__setobj__(create(delegator.to_sym, :with_votes, upvotes: up,
                                                               downvotes: down))
    @votable = delegator
  end

  def page_showing(votable)
    post_path(votable.post)
  end

  def cast_vote(*traits)
    post send(votable.create_vote_path, votable),
         params: { vote: attributes_for(:vote, *traits) }
  end
end
