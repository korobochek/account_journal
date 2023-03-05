# frozen_string_literal: true

require 'csv'

module CSVAdapter
  class FileNotFound < StandardError; end

  class CSVParser
    attr_reader :filename, :validator

    def initialize(filename, validator)
      @filename = filename
      @validator = validator
    end

    def parse!
      CSV.foreach(filename, headers: false) do |row|
        p row
      end
    rescue Errno::ENOENT => e
      raise(FileNotFound, e.message)
    end
  end
end
