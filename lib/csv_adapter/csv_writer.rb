# frozen_string_literal: true

require 'csv'
require_relative 'file_not_found_error'

module CSVAdapter
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
      raise(CSVAdapter::FileNotFoundError, e.message)
    end
  end
end
