class HardWorker < Struct.new(:name, :count, :salt)
  
  def perform
    raise name if name == 'crash'

    sleep count
  end
  
end