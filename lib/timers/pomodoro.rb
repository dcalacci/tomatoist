class Pomodoro < Timer
  property :duration, Integer, :default => 25*60 
  def name
    'Pomodoro'
  end
end
