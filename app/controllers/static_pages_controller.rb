class StaticPagesController < ApplicationController
  def home
    order = params[:order] || :recent
    @posts = Post.includes(:user).send(order).page(params[:page])
  end

  def about
  end

  def contact
  end

  def help
  end
end
