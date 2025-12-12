class TextNormalizerService
  def initialize(text)
    @text = text.to_s
    @replacements = TypelitConfig.replacements
  end

  def normalize
    result = @text.dup

    @replacements.each do |from, to|
      result.gsub!(from, to)
    end

    # Normalize multiple spaces to single space (but preserve newlines)
    result.gsub!(/ +/, " ")

    # Normalize multiple newlines to double newline (paragraph break)
    result.gsub!(/\n{3,}/, "\n\n")

    # Remove leading/trailing whitespace from each line
    result = result.lines.map(&:strip).join("\n")

    # Final trim
    result.strip
  end
end
