require "tempfile"

class PlantIdentifier
  PROMPT = <<~PROMPT.freeze
    Identify the houseplant in this photo. Return only its most likely botanical name followed by a hyphen and
    its common English name, for example: Monstera deliciosa - Swiss cheese plant. Do not add explanation.
    If the image does not contain a plant or identification is impossible, return: Unable to identify.
  PROMPT

  class_attribute :provider, default: nil

  class << self
    def identify(upload)
      return provider.call(upload) if provider

      with_extension_preserved(upload) do |path|
        response = RubyLLM.chat.ask(PROMPT, with: { image: path })
        normalize(response.content)
      end
    end

    def normalize(content)
      result = content.to_s.strip.gsub(/[*_`]/, "").lines.first.to_s.strip
      if result.blank? || result.casecmp?("Unable to identify.")
        raise ArgumentError, "The plant could not be identified"
      end

      result.truncate(120)
    end

    private

    def with_extension_preserved(upload)
      extension = File.extname(upload.original_filename)
      Tempfile.create(["plant-identification", extension]) do |file|
        IO.copy_stream(upload.tempfile, file)
        file.flush
        yield file.path
      end
    end
  end
end
