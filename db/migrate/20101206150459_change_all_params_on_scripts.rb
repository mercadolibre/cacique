class ChangeAllParamsOnScripts < ActiveRecord::Migration
  def self.up
    counter=0
    Circuit.source_code_like("params.").each do |script|
      script.source_code=script.source_code.gsub(/params\.\w+/){|value| 'data[:'+value.gsub('params.','').to_s + ']'}
      script.save
      counter=counter+1
    end
    puts "se modificaron #{counter}"
  end

  def self.down
  end
end
