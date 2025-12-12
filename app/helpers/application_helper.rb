module ApplicationHelper
  def highlight_search_result(text, query)
    return text if query.blank?

    # Truncate around the first match
    match_index = text.downcase.index(query.downcase)
    if match_index
      start_index = [match_index - 50, 0].max
      end_index = [match_index + query.length + 100, text.length].min
      excerpt = text[start_index...end_index]
      excerpt = "...#{excerpt}" if start_index > 0
      excerpt = "#{excerpt}..." if end_index < text.length
    else
      excerpt = truncate(text, length: 150)
    end

    highlight(excerpt, query, highlighter: '<mark class="bg-yellow-200 px-0.5 rounded">\1</mark>')
  end
end
