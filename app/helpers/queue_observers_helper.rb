module QueueObserversHelper

  def show_min_sec time_in_seconds
    min, sec = time_in_seconds / 60, time_in_seconds % 60
    "#{min}m #{sec}s"
  end

end
