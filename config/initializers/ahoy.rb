class Ahoy::Store < Ahoy::Stores::ActiveRecordStore
  # customize here
  def exclude?
    bot? || request.ip == "192.168.1.1"
  end

  def user
    controller.current_user
  end

  def report_exception(e)
    puts e
  end
end
