module ArrayExtension

  def /(number_of_buckets)
    buckets = (1..number_of_buckets).collect { [] }
    while self.any? do
      buckets.each do |bucket|
        bucket << self.shift if self.any?
      end
    end
    buckets
  end

end
