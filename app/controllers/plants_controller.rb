class PlantsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_plant, only: %i[show edit update destroy watered_today]

  def index
    @plants = current_user.plants
  end

  def show
  end

  def new
    @plant = Plant.new
  end

  def create
    @plant = current_user.plants.build(plant_params)
    if @plant.save
      redirect_to @plant, notice: "Plant was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @plant.update(plant_params)
      redirect_to @plant, notice: "Plant was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def watered_today
    @plant.update!(last_watered_on: Date.current)
    redirect_back fallback_location: plant_path(@plant), notice: "#{@plant.nickname} was watered today."
  end

  def destroy
    @plant.destroy
    redirect_to plants_path, notice: "Plant was successfully deleted."
  end

  private

  def set_plant
    @plant = current_user.plants.find(params[:id])
  end

  def plant_params
    params.require(:plant).permit(:nickname, :species, :location, :last_watered_on, :photo)
  end
end
