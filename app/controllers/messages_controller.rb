class MessagesController < ApplicationController
  SYSTEM_PROMPT = <<~PROMPT
    You are an experienced houseplant specialist.

    I am a nervous beginner. I have killed houseplants before and I feel guilty about it.
    I need reassurance and one clear thing to do next, not a list of possibilities.

    Diagnose the single most likely cause of the problem I describe, based on the plant details I give you.
    Say which cause you think it is and why. Then give me one specific action to take this week.

    Answer in Markdown. Keep it under 150 words. No numbered lists of alternatives.
  PROMPT

  def create
    @chat = current_user.chats.find(params[:chat_id])
    @plant = @chat.plant

    @message = Message.new(message_params)
    @message.chat = @chat
    @message.role = "user"

    @message.save ? respond_with_ai : respond_with_errors
  end

  private

  def respond_with_ai
    @assistant_message = @chat.messages.create!(role: "assistant", content: "")
    response = ask_llm
    @assistant_message.update!(content: response.content)
    @chat.generate_title_from_first_message

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to chat_path(@chat) }
    end
  end

  def respond_with_errors
    respond_to do |format|
      format.turbo_stream { render_invalid_form }
      format.html { render "chats/show", status: :unprocessable_entity }
    end
  end

  def render_invalid_form
    render turbo_stream: turbo_stream.update(
      "new_message_container",
      partial: "messages/form",
      locals: { chat: @chat, message: @message }
    )
  end

  def build_conversation_history
    current_message_ids = [@message.id, @assistant_message&.id].compact

    @chat.messages.where.not(id: current_message_ids).each do |message|
      @ruby_llm_chat.add_message(
        role: message.role,
        content: message.content.presence || "[Plant photo attached]"
      )
    end
  end

  def ask_llm
    @ruby_llm_chat = RubyLLM.chat

    build_conversation_history

    @ruby_llm_chat.with_instructions(instructions)

    prompt = @message.content.presence || "Please diagnose the problem visible in this plant photo."

    return stream_response(prompt) unless @message.image.attached?

    @message.image.blob.open do |image_file|
      stream_response(prompt, image_path: image_file.path)
    end
  end

  def stream_response(prompt, image_path: nil)
    attachments = image_path ? { image: image_path } : {}

    @ruby_llm_chat.ask(prompt, with: attachments) do |chunk|
      next if chunk.content.blank?

      @assistant_message.content += chunk.content
      broadcast_replace(@assistant_message)
    end
  end

  def broadcast_replace(message)
    Turbo::StreamsChannel.broadcast_replace_to(
      @chat,
      target: helpers.dom_id(message),
      partial: "messages/message",
      locals: { message: message }
    )
  end

  def message_params
    params.require(:message).permit(:content, :image)
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
