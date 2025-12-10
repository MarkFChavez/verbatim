require "gepub"
require "nokogiri"

class EpubParserService
  Result = Struct.new(:title, :author, :cover, :chapters, keyword_init: true)
  ChapterData = Struct.new(:title, :content, keyword_init: true)

  def self.min_chapter_length
    VerbatimConfig.chapter_min_length
  end

  def self.skip_title_patterns
    VerbatimConfig.skip_title_patterns
  end

  def initialize(epub_file)
    @epub_file = epub_file
  end

  def parse
    book = GEPUB::Book.parse(@epub_file)

    Result.new(
      title: extract_title(book),
      author: extract_author(book),
      cover: extract_cover(book),
      chapters: extract_chapters(book)
    )
  end

  private

  def extract_title(book)
    book.title&.to_s || "Unknown Title"
  end

  def extract_author(book)
    book.creator&.to_s || "Unknown Author"
  end

  def extract_cover(book)
    # Find cover image by looking for item with 'cover-image' property
    cover_item = book.manifest.item_list.values.find do |item|
      item.properties&.include?("cover-image")
    end

    # Fallback: look for item referenced by 'cover' meta tag (EPUB2 style)
    unless cover_item
      cover_meta = book.metadata.oldstyle_meta.find { |m| m["name"] == "cover" }
      if cover_meta
        cover_item = book.manifest.item_list[cover_meta["content"]]
      end
    end

    return nil unless cover_item

    {
      data: cover_item.content,
      media_type: cover_item.media_type,
      filename: File.basename(cover_item.href)
    }
  end

  def find_bodymatter_start(book)
    # Find EPUB 3 navigation document
    nav_item = book.manifest.item_list.values.find do |item|
      item.properties&.include?("nav")
    end
    return nil unless nav_item

    # Parse nav document and find landmarks
    nav_doc = Nokogiri::XML(nav_item.content)
    nav_doc.remove_namespaces!

    # Find landmarks nav element
    landmarks_nav = nav_doc.at_css('nav[type="landmarks"]')
    return nil unless landmarks_nav

    # Find bodymatter landmark
    bodymatter = landmarks_nav.at_css('a[type="bodymatter"]')
    return nil unless bodymatter

    # Return href without fragment
    bodymatter["href"]&.split("#")&.first
  end

  def find_text_start_from_guide(book)
    # EPUB 2 fallback: look for guide element in OPF
    # gepub exposes this via the package
    book.package.instance_variable_get(:@opf)&.css("guide reference")&.each do |ref|
      return ref["href"]&.split("#")&.first if ref["type"] == "text"
    end
    nil
  rescue
    nil
  end

  def extract_chapters(book)
    chapters = []
    seen_content = Set.new
    manifest_items = book.manifest.item_list

    # Find where main content starts
    start_href = find_bodymatter_start(book) || find_text_start_from_guide(book)
    found_start = start_href.nil?  # If no landmark found, include all chapters

    book.spine.itemref_list.each do |itemref|
      item = manifest_items[itemref.idref]
      next unless item&.media_type&.include?("html")

      # Skip front matter until we reach bodymatter start
      if !found_start && start_href && item.href&.include?(start_href)
        found_start = true
      end
      next unless found_start

      content = item.content.force_encoding("UTF-8")
      doc = Nokogiri::HTML(content)

      # Extract title from heading or use item id
      title = extract_chapter_title(doc) || itemref.idref.to_s.titleize

      # Skip front/back matter based on title
      next if skip_chapter?(title)

      # Extract text content
      text = extract_text_content(doc)
      next if text.blank?

      # Normalize special characters
      text = TextNormalizerService.new(text).normalize

      # Skip duplicate content (some epubs have redundant spine items)
      content_hash = Digest::MD5.hexdigest(text)
      next if seen_content.include?(content_hash)
      seen_content.add(content_hash)

      chapters << ChapterData.new(
        title: title,
        content: text
      )
    end

    merge_short_chapters(chapters)
  end

  def merge_short_chapters(chapters)
    return chapters if chapters.empty?

    merged = []
    current = chapters.first

    chapters[1..].each do |chapter|
      if current.content.length < self.class.min_chapter_length
        # Merge with next chapter
        current = ChapterData.new(
          title: [ current.title, chapter.title ].compact.join(" - "),
          content: "#{current.content} #{chapter.content}".strip
        )
      else
        merged << current
        current = chapter
      end
    end

    merged << current if current
    merged
  end

  def skip_chapter?(title)
    return false if title.blank?
    pattern = self.class.skip_title_patterns
    return false unless pattern
    title.match?(pattern)
  end

  def extract_chapter_title(doc)
    # Try various heading elements
    %w[h1 h2 h3 title].each do |tag|
      heading = doc.at_css(tag)
      return heading.text.strip if heading && heading.text.present?
    end
    nil
  end

  def extract_text_content(doc)
    # Remove script and style elements
    doc.css("script, style, nav, header, footer").remove

    # Get body content, handling potential nil
    body = doc.at_css("body") || doc.root
    return "" unless body

    # Extract paragraphs preserving structure
    paragraphs = []

    # Look for paragraph tags first
    body.css("p").each do |p|
      text = p.text.gsub(/\s+/, " ").strip
      paragraphs << text if text.present?
    end

    # If no paragraphs found, fall back to body text with div breaks
    if paragraphs.empty?
      body.css("div, p, br").each do |el|
        if el.name == "br"
          paragraphs << ""
        else
          text = el.text.gsub(/\s+/, " ").strip
          paragraphs << text if text.present?
        end
      end
    end

    # If still empty, just get all text
    if paragraphs.empty?
      return body.text.gsub(/\s+/, " ").strip
    end

    # Join paragraphs with double newlines
    paragraphs.reject(&:blank?).join("\n\n")
  end
end
