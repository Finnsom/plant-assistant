class PlantsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_plant, only: %i[show edit update destroy watered_today]
  before_action :set_weather, only: %i[index show]

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

  def identify
    photo = params[:photo]
    unless valid_photo?(photo)
      return render json: { error: "Choose a plant photo first." }, status: :unprocessable_entity
    end

    render json: { species: PlantIdentifier.identify(photo) }
  rescue ArgumentError => e
    render json: { error: e.message }, status: :unprocessable_entity
  rescue StandardError => e
    Rails.logger.error("Plant identification failed: #{e.class}: #{e.message}")
    render json: { error: "The plant could not be identified right now. Please try again." }, status: :bad_gateway
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
    params.require(:plant).permit(:nickname, :species, :location, :last_watered_on, :photo, :outside)
  end

  def set_weather
    @weather = WeatherForecast.current
  end

  def valid_photo?(photo)
    photo.respond_to?(:content_type) && Plant::IMAGE_CONTENT_TYPES.include?(photo.content_type) &&
      photo.size <= Plant::MAX_IMAGE_SIZE
  end
end
