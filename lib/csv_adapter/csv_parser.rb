# frozen_string_literal: true

require 'csv'
require_relative 'file_not_found_error'

module CSVAdapter
  class CSVParser
    attr_reader :filename, :validator_proc

    def initialize(filename, validator_proc)
      @filename = filename
      @validator_proc = validator_proc
    end

    def parse!
      result = []
      CSV.foreach(filename, headers: false) do |row|
        result << validator_proc.call(row) unless row.empty?
      end
      result
    rescue Errno::ENOENT => e
      raise(CSVAdapter::FileNotFoundError, e.message)
    end
  end
end
