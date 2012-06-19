class TxnsController < ApplicationController
  before_filter :signed_in_user, only: [:create, :destroy]
  before_filter :correct_user,   only: :destroy

  def create
    @txn = current_user.txns.build(params[:txn])
    if @txn.save
      flash[:success] = 'Transaction created!'
      redirect_to root_path
    else
      @feed_items = []
      render 'static_pages/home'
    end
  end

  def destroy
    @txn.destroy
    redirect_to root_path
  end

  private

  def correct_user
    @txn = current_user.txns.find(params[:id])
  rescue
    redirect_to root_path
  end
end
