module Core
  module Storage
    attr_accessor :root
    
    def contains?(path)
      File.exists? fullpath(path)
    end
    
    def readable?(path)
      File.readable? fullpath(path)
    end
    
    def expired?(path)
      false
    end
  
    def load(path)
      path = fullpath(path)
      
      read(path) { |file| file.read } if File.readable? path
    end
    
    def unload(path)
      content = load(path)
      
      remove(path)
      
      content
    end
    
    def store(path, content)
      path = fullpath(path)
      dir  = File.dirname(path)
      
      FileUtils.mkpath dir unless Dir.exists? dir
      
      write(path) do |file|
        file.write content
        file.flush
      end
    end
    
    def remove(path)
      FileUtils.remove_entry_secure fullpath(path)
    end
    
    def fullpath(path)
      File.join(partition(path).select { |part| part != '.' })
    end
    
    def each
      Dir.foreach(root) do |path|
        yield path unless path.start_with? '.'
      end
    end
    
    protected

    include Core::Storage::Binary
    
    def partition(path)
      dir  = File.dirname(path)
      file = File.basename(path)

      [root, dir, file] 
    end
  end  
end
