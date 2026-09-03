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
      @assistant_message = @chat.messages.create(role: "assistant", content: "")

      response = ask_llm
      @assistant_message.update(content: response.content)

      @chat.generate_title_from_first_message

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to chat_path(@chat) }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.update("new_message_container", partial: "messages/form", locals: { chat: @chat, message: @message }) }
        format.html { render "chats/show", status: :unprocessable_entity }
      end
    end
  end

  private

  def build_conversation_history
    @chat.messages.each do |message|
      next if message.content.blank?

      @ruby_llm_chat.add_message(message)
    end
  end

  def ask_llm
    @ruby_llm_chat = RubyLLM.chat

    build_conversation_history

    @ruby_llm_chat.with_instructions(instructions)

    @ruby_llm_chat.ask(@message.content) do |chunk|
      next if chunk.content.blank?

      @assistant_message.content += chunk.content
      broadcast_replace(@assistant_message)
    end
  end

  def broadcast_replace(message)
    Turbo::StreamsChannel.broadcast_replace_to(@chat, target: helpers.dom_id(message), partial: "messages/message", locals: { message: message })
  end

  def message_params
    params.require(:message).permit(:content)
  end

  def plant_context
    details = ["The plant is a #{@plant.species}, nicknamed #{@plant.nickname}."]
    details << "It is kept in the #{@plant.location}." if @plant.location.present?
    details << "It was last watered on #{@plant.last_watered_on}." if @plant.last_watered_on.present?
    details << "Today's date is #{Date.today.strftime('%-d %B %Y')}."
    details.join(" ")
  end

  def instructions
    [SYSTEM_PROMPT, plant_context].join("\n\n")
  end
end
