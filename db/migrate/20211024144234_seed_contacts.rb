class SeedContacts < ActiveRecord::Migration[6.1]
  def change
    new_contacts = [
      {first_name: 'Michael', last_name: 'Scott', email: 'twss@dunmif.com', phone_number: '4444555566', is_active: true, comment: 'Cringe'},
      {first_name: 'Dwight', last_name: 'Schrute', email: 'ninja@dunmif.com', phone_number: '3476876887', is_active: true, comment: 'Bears, beets, Battlestar Galactica'},
      {first_name: 'Kevin', last_name: 'Malone', email: 'cookies@dunmif.com', phone_number: '3876786878', is_active: true},
      {first_name: 'Angela', last_name: 'Martin', email: 'lovecats@dunmif.com', phone_number: '87684354658', is_active: true},
      {first_name: 'Stanley', last_name: 'Hudson', email: 'sudoku@dunmif.com', phone_number: '387688754', is_active: true, comment: 'Zzzz...'}
    ]

    new_contacts.each do |contact|
      @contact = Contact.create!(contact)
      ChangeLog.create!({contact_id: @contact[:id], details: "Created contact: #{@contact[:first_name]} #{@contact[:last_name]}, #{@contact[:email]}, #{contact[:phone_number]}"})
    end
  end
end
