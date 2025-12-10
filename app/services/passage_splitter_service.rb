class PassageSplitterService
  SENTENCE_ENDINGS = /([.!?]["']?\s+)/
  PARAGRAPH_BREAK = "\n\n"

  def initialize(text)
    @text = text.to_s.strip
    @min_length = VerbatimConfig.passage_min_length
    @max_length = VerbatimConfig.passage_max_length
  end

  def split
    return [] if @text.blank?

    passages = []
    current_passage = ""

    # Split into paragraphs first, then process each
    paragraphs = @text.split(/\n\n+/)

    paragraphs.each do |paragraph|
      paragraph = paragraph.strip
      next if paragraph.blank?

      # Check if adding this paragraph would exceed max length
      potential_passage = if current_passage.empty?
        paragraph
      else
        "#{current_passage}#{PARAGRAPH_BREAK}#{paragraph}"
      end

      if potential_passage.length >= @min_length && potential_passage.length <= @max_length
        # Perfect length, save it
        passages << potential_passage
        current_passage = ""
      elsif potential_passage.length > @max_length
        if current_passage.length >= @min_length
          # Current passage is good enough, save it
          passages << current_passage
          current_passage = paragraph
        elsif current_passage.empty?
          # Single paragraph exceeds max - split by sentences
          split_large_paragraph(paragraph, passages)
          current_passage = ""
        else
          # Need to include this paragraph, split current + new by sentences
          split_large_paragraph(potential_passage, passages)
          current_passage = ""
        end
      else
        # Still building up the passage
        current_passage = potential_passage
      end
    end

    # Don't forget the last passage
    if current_passage.present?
      if passages.any? && current_passage.length < @min_length
        # Merge with previous if too short
        last_passage = passages.pop
        passages << "#{last_passage}#{PARAGRAPH_BREAK}#{current_passage}"
      else
        passages << current_passage
      end
    end

    passages
  end

  private

  # Split a large text block by sentences when it exceeds MAX_LENGTH
  def split_large_paragraph(text, passages)
    sentences = split_into_sentences(text)
    current = ""

    sentences.each do |sentence|
      potential = current.empty? ? sentence : "#{current} #{sentence}"

      if potential.length >= @min_length && potential.length <= @max_length
        passages << potential.strip
        current = ""
      elsif potential.length > @max_length
        if current.length >= @min_length
          passages << current.strip
          current = sentence
        else
          # Sentence itself is very long, just add it
          passages << potential.strip
          current = ""
        end
      else
        current = potential
      end
    end

    # Handle remainder
    if current.present?
      if passages.any? && current.length < @min_length
        last = passages.pop
        passages << "#{last} #{current}".strip
      else
        passages << current.strip
      end
    end
  end

  def split_into_sentences(text)
    # Normalize paragraph breaks to spaces for sentence splitting
    normalized = text.gsub(/\n+/, " ")

    # Split on sentence-ending punctuation while preserving the punctuation
    parts = normalized.split(SENTENCE_ENDINGS)

    sentences = []
    parts.each_slice(2) do |content, delimiter|
      sentence = "#{content}#{delimiter}".strip
      sentences << sentence if sentence.present?
    end

    sentences
  end
end
