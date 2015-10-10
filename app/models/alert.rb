class Alert
  attr_reader :message, :icon, :url

  def initialize(message, icon, url)
    @message = message
    @icon = icon
    @url = url
  end
end
