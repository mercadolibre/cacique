class File

    def self.native_path(path)
    expanded_path = File.expand_path(path)
    expanded_path.gsub!('/', '\\') if PLATFORM['win32']
    expanded_path
  end

end
