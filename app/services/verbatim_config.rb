class VerbatimConfig
  class << self
    def config
      @config ||= load_config
    end

    def reload!
      @config = load_config
    end

    # Passage settings
    def passage_min_length
      config.dig("passage", "min_length") || 150
    end

    def passage_max_length
      config.dig("passage", "max_length") || 300
    end

    # Chapter settings
    def chapter_min_length
      config.dig("chapter", "min_length") || 200
    end

    # Skip patterns as regex
    def skip_title_patterns
      patterns = config["skip_patterns"] || []
      return nil if patterns.empty?
      Regexp.new("\\b(#{patterns.join('|')})\\b", Regexp::IGNORECASE | Regexp::EXTENDED)
    end

    # Character replacements hash
    def replacements
      config["replacements"] || {}
    end

    private

    def load_config
      config_path = Rails.root.join("config", "typing_parameters.yml")
      if File.exist?(config_path)
        YAML.load_file(config_path) || {}
      else
        {}
      end
    end
  end
end
