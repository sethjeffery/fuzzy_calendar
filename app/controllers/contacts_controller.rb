class ContactsController < ApplicationController
  def create
    @contact = Contact.new(contact_params)

    if @contact.valid? && verify_recaptcha(model: @contact, message: "There was an error with the reCAPTCHA human test. Please try again.")
      ContactMailer.contact(@contact).deliver_now!
      redirect_to thankyou_contact_path, notice: "Thank you for your message! I will endeavour to read it and reply!"
    else
      render :show
    end
  end

  private

  def contact_params
    params.require(:contact).permit(:name, :email, :message)
  end
end
