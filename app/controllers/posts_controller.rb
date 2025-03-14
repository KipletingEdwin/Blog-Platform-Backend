class PostsController < ApplicationController
    before_action :authenticate_request, except: [:index, :show] # Protect write operations

  
    # ✅ Get All Posts
    def index
      posts = Post.all.order(created_at: :desc)
      render json: posts, status: :ok
    end
  
    # ✅ Show a Single Post
    def show
      post = Post.find_by(id: params[:id])
      if post
        render json: post, status: :ok
      else
        render json: { error: "Post not found" }, status: :not_found
      end
    end
  
    # ✅ Create a New Post
    def create
      puts "🔍 Received Post Params: #{params.inspect}"  # Debugging Line
    
      # ✅ Make sure we reference `content`, NOT `text`
      post = @current_user.posts.build(post_params)
    
      if post.save
        render json: post, status: :created
      else
        render json: { error: post.errors.full_messages }, status: :unprocessable_entity
      end
    end
    
    
  
    # ✅ Update a Post
    def update
      # if post.user_id == current_user.id  #Check ownership
        
      post = current_user.posts.find_by(id: params[:id])
      if post&.update(post_params)
        render json: post, status: :ok
      else
        render json: { error: "Failed to update post" }, status: :unprocessable_entity
      end
    end
  
    # ✅ Delete a Post
    def destroy
      post = current_user.posts.find_by(id: params[:id])
      if post&.destroy
        render json: { message: "Post deleted successfully" }, status: :ok
      else
        render json: { error: "Unable to delete post" }, status: :forbidden
      end
    end
  
    private
  
    # ✅ Strong Parameters
    def post_params
      params.require(:post).permit(:title, :content, :category, :isTrending)
    end
  end
  