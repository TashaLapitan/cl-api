class Contact < ApplicationRecord
  has_many :change_log, :dependent => :delete_all

  scope :active, -> {where(is_active: true)}
end
