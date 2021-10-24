class ContactController < ApplicationController

  #[GET]
  def all_active
    @contacts = Contact.active.as_json(include: {change_log: { only: [:created_at, :details] }})
    render json: @contacts
  end

  #[POST]
  def new_contact

    existing_contact = Contact.find_by(email: params[:email])
    if existing_contact
      error = existing_contact.is_active ?
                {"reason": "active", "message": "The contact with the email #{existing_contact[:email]} is already in your list"}
                : {"reason": "inactive", "message": "A contact with the email #{existing_contact[:email]} had been previously deleted from your list. Would you like to restore the archived contact?"}
      error[:contact_id] = existing_contact.id
      render json: {'error': error} and return
    end

    create_new_contact(params)
  end

  #SHARED METHODS
  def create_new_contact(new_contact = nil)
    if new_contact[:first_name].blank? || new_contact[:last_name].blank? || new_contact[:email].blank? || new_contact[:phone_number].blank?
      render json: {'error': "Please provide valid data (first name, last name, email and phone number)"}, status: :bad_request and return
    end

    comment = new_contact[:comment].present? ? new_contact[:comment] : nil
    @contact = Contact.create!({first_name: new_contact[:first_name],
                                last_name: new_contact[:last_name],
                                email: new_contact[:email],
                                phone_number: new_contact[:phone_number],
                                comment: comment,
                                is_active: true})

    ChangeLog.create!({contact_id: @contact[:id], details: "Created contact: #{@contact[:first_name]} #{@contact[:last_name]}, #{@contact[:email]}, #{@contact[:phone_number]}"})

    render json: with_history(@contact)
  end

  private

  def with_history(contact)
    contact.as_json(include: {change_log: { only: [:created_at, :details] }})
  end

end
