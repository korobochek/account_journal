# frozen_string_literal: true

require 'csv'

module CSVAdapter
  class FileNotFound < StandardError; end

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
      raise(FileNotFound, e.message)
    end
  end
end
