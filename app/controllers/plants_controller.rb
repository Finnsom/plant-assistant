class PlantsController < ApplicationController
  before_action :authenticate_user!

  def index
    @plants = current_user.plants
  end

  def show
    @plant = current_user.plants.find(params[:id])
  end

  def new
  end

  def edit
  end
end
