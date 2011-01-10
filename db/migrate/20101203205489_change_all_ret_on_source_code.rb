class ChangeAllRetOnSourceCode < ActiveRecord::Migration
  def self.up
    counter=0
    Circuit.source_code_like("ret.").each do |script|
      script.source_code=script.source_code.gsub("ret.","ret_")
      script.save
      counter=counter+1
    end
    puts "se modificaron #{counter}"
  end

  def self.down
    Circuit.source_code_like("ret_").each do |script|
      script.source_code.gsub("ret_","ret.")
      script.save
    end
  end
end
