class ApplicationMailer < ActionMailer::Base
  include Roadie::Rails::Automatic

  default from: "fuzzy@fuzzycalendar.com"
  layout 'mailer'
end
