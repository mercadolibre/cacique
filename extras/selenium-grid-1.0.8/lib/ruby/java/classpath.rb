module Java

  class Classpath
    require 'pathname'

    def initialize(root_dir)
      @root = root_dir
      @locations = []
      self
    end

    def <<(paths)
      @locations = (@locations << Dir[@root + '/' + paths]).flatten
      self
    end

    def definition
      @locations.map {|path| File.native_path(path)}.join(self.separator)

    end

    def separator
     PLATFORM['win32'] ? ";" : ":"
    end

  end

end
