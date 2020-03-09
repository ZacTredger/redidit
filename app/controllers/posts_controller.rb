class PostsController < ApplicationController
  before_action :reject_unless_user_logged_in, except: :show
  before_action :set_post_var, except: %i[show create]
  before_action :correct_user, only: %i[edit update destroy]

  def show
    if (@post = Post.includes(:user, vote_from: current_user)
                    .find_by(id: params[:id]))
      comments
      @comment = @post.comments.build
      return
    end

    flash[:error] = 'Post not found'
    redirect_to root_path
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params.merge(user_id: current_user.id))
    return (render :new) unless @post.save

    redirect_to @post
  end

  def edit
    return if @post

    flash[:error] = 'Post not found'
    redirect_to root_path
  end

  def update
    return (render :edit) unless
      @post&.update(post_params.merge(user_id: current_user.id))

    redirect_to @post
  end

  def destroy
    @post.delete
    flash[:success] = 'Post deleted'
    redirect_to root_path
  end

  private

  def post_params
    params.require(:post).permit(:title, :link, :body)
  end

  # Before-filters
  # Sets the instance var @post, which is used to test whether user is correct
  def set_post_var
    @post = Post.includes(:user).find_by(id: params[:id])
  end

  # Tests whether the user trying to interact with the post is its author
  def correct_user
    super(@post.user_id)
  end

  def comments
    @comments ||=
      @post.comments.includes(:user, vote_from: current_user)
                    .send(params[:order] || :recent)
  end
end
