class UsersController < ApplicationController
  before_action :logged_in_user, except: [:create, :new]
  before_action :admin_user, only: :destroy
  before_action :find_user, except: [:create, :new, :index]
  before_action :correct_user, only: [:edit, :update]

  def create
    @user = User.new user_params
    if @user.save
      @user.send_activation_email
      flash[:info] = t ".checkmail"
      redirect_to root_path
    else
      render :new
    end
  end

  def new
    @user = User.new
  end

  def index
    @users = User.activated.paginate page: params[:page]
  end

  def show
  end

  def edit
  end

  def update
    if @user.update_attributes user_params
      flash[:success] = t ".updated"
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = t ".deleted"
    redirect_to users_url
  end

  private
  def user_params
    params.require(:user).permit :name, :email, :password,
      :password_confirmation
  end

  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = t ".login_danger"
      redirect_to login_url
    end
  end

  def correct_user
    unless @user.current_user? current_user
      flash[:danger] = t ".other_user"
      redirect_to root_path
    end
  end

  def admin_user
    redirect_to root_url unless current_user.is_admin?
  end

  def find_user
    @user = User.find_by id: params[:id]
    unless @user
      flash[:danger] = t ".not_found"
      redirect_to root_path
    end
  end
end
