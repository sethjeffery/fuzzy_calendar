class ContactMailer < ApplicationMailer
  def contact(contact)
    @contact = contact
    mail to: "fuzzy@fuzzycalendar.com", subject: "Feedback received from Fuzzy Calendar website", from: @contact.email
  end
end
