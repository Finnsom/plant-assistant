class MessagesController < ApplicationController
  SYSTEM_PROMPT = "
    You are an experienced houseplant specialist.

    I am a nervous beginner. I have killed houseplants before and I feel guilty about it. I need reassurance and one clear thing to do next, not a list of possibilities.

    Diagnose the single most likely cause of the problem I describe, based on the plant details I give you. Say which cause you think it is and why. Then give me one specific action to take this week.

    Answer in Markdown. Keep it under 150 words. No numbered lists of alternatives.
  "

  def create
    @chat = current_user.chats.find(params[:chat_id])
    @plant = @chat.plant

    @message = Message.new(message_params)
    @message.chat = @chat
    @message.role = "user"

    if @message.save
      ruby_llm_chat = RubyLLM.chat
      response = ruby_llm_chat.with_instructions(instructions).ask(@message.content)
      Message.create(role: "assistant", content: response.content, chat: @chat)

      redirect_to chat_path(@chat)
    else
      render "chats/show", status: :unprocessable_entity
    end
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end

  def plant_context
    details = ["The plant is a #{@plant.species}, nicknamed #{@plant.nickname}."]
    details << "It is kept in the #{@plant.location}." if @plant.location.present?
    details << "It was last watered on #{@plant.last_watered_on}." if @plant.last_watered_on.present?
    details.join(" ")
  end

  def instructions
    [SYSTEM_PROMPT, plant_context].join("\n\n")
  end
end
