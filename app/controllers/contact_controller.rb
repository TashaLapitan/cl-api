class ContactController < ApplicationController
  before_action :declare_changeable_params, :only => :update_contact

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

  #[PUT]
  def update_contact

    @contact = contact_with_valid_id(params[:contact_id])
    if @contact.blank?
      return
    end

    unless params[:email] === @contact.email
      render json: {'error': "You cannot change a contact's email"} and return
    end

    new_info = {}
    @changeable_fields.each do |key|
      if params[key].present? && params[key] != @contact[key.to_s]
        new_info[key] = params[key]
      end
    end

    @contact.update!(new_info)
    ChangeLog.create!({contact_id: @contact.id,
                       details: "Updated: #{new_info.keys.map{|key| "new #{key.to_s.split("_").join(" ")} - #{new_info[key]}"}.join(", ")}"})

    render json: with_history(@contact)
  end

  #[PUT]
  def soft_delete
    @contact = contact_with_valid_id(params[:contact_id])
    if @contact.blank?
      return
    end
    @contact.update!({ is_active: false })
    ChangeLog.create!({contact_id: @contact.id, details: "Deactivated"})

    render json: {'success': true, status: :ok}
  end

  #[PUT]
  def restore
    @contact = contact_with_valid_id(params[:contact_id])
    if @contact.blank?
      return
    end
    @contact.update!({is_active: true})
    ChangeLog.create!({contact_id: @contact.id, details: "Restored"})

    render json: with_history(@contact)
  end

  #[PUT]
  def overwrite
    @contact = contact_with_valid_id(params[:contact_id])
    if @contact.blank?
      return
    end
    @contact.destroy!

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

  def contact_with_valid_id(contact_id = nil)

    unless contact_id.present?
      render json: {'error': 'Please provide a valid contact ID'} and return nil
    end

    @contact = Contact.find_by(id: params[:contact_id])
    if @contact.blank?
      render json: {'error': 'Please provide a valid contact ID'} and return nil
    end
    @contact
  end

  def with_history(contact)
    contact.as_json(include: {change_log: { only: [:created_at, :details] }})
  end

  private

  def declare_changeable_params
    @changeable_fields = [:first_name, :last_name, :phone_number, :comment]
  end

end
