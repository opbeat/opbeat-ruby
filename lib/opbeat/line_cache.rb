module Opbeat
  class LineCache

    CACHE = {}

    def self.all path
      CACHE[path] ||= begin
        File.readlines(path)
      rescue
        []
      end
    end

    def self.find path, line
      return nil if line < 1
      all(path)[line - 1]
    end

  end
end
