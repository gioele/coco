module Coco

  # I format coverages data for console output.
  #
  class ConsoleFormatter

    # Public: Get a colored report, formatted for console output.
    #
    # Returns percent covered and associated filenames as a multilines
    # or a single line String.
    #
    def format
      @config[:single_line_report] ? single_line_message : multilines_message
    end

    # Get the link for the report's index file.
    #
    # Returns String.
    #
    def link
      unless @formatted_output.empty?
        'See file://' +
        File.expand_path(File.join(HtmlDirectory.new(@config).coverage_dir,
                                   'index.html'))
      end
    end

    # Public: Creates a new ConsoleFormatter.
    #
    # uncovered - An Array list of uncovered files.
    # threshold - The Fixnum percentage threshold.
    # result    - A CoverageResult.
    # config    - A Configuration.
    #
    def initialize(uncovered, threshold, result, config)
      @uncovered = uncovered
      @result = result

      @formatted_output = []
      compute_percentage
      add_percentage_to_uncovered
      @formatted_output.sort!
      @formatted_output.map! do |percentage, filename|
        text = ColoredString.new "#{percentage}% #{filename}"
        if percentage <= 50
          text.red
        elsif percentage >= threshold
          text.green
        else
          text.yellow
        end
      end
      @summary = Summary.new(result, uncovered)
      @config = config
    end

    private

    def compute_percentage
      @result.not_covered_enough.each do |filename, coverage|
        percentage = CoverageStat.coverage_percent(coverage)
        @formatted_output << [percentage, filename]
      end
    end

    def add_percentage_to_uncovered
      @uncovered.each { |filename| @formatted_output << [0, filename] }
    end

    def single_line_message
      ColoredString.new(@summary.to_s).yellow
    end

    def multilines_message
      @formatted_output.join("\n") + "\n" + @summary.to_s + "\n"
    end
  end
end
