class ChatsController < ApplicationController
  def create
    @plant = Plant.find(params[:plant_id])

    @chat = Chat.new(title: "Untitled")
    @chat.plant = @plant
    @chat.user = current_user

    if @chat.save
      redirect_to chat_path(@chat)
    else
      redirect_to plant_path(@plant), alert: "Could not start a chat."
    end
  end

  def show
    @chat = current_user.chats.find(params[:id])
    @message = Message.new
  end
end
