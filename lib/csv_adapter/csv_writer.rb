# frozen_string_literal: true

require 'csv'

module CSVAdapter
  class FileNotFound < StandardError; end

  class CSVWriter
    attr_reader :filename, :validator_proc

    def initialize(filename, data)
      @filename = filename
      @data = data
    end

    def write!
      CSV.open(@filename, 'w') do |csv|
        @data.each do |row|
          csv << row
        end
      end
    rescue Errno::ENOENT => e
      raise(FileNotFound, e.message)
    end
  end
end
