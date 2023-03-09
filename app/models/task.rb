class Task < ApplicationRecord
  belongs_to :category
  belongs_to :owner, class_name: 'User'
  has_many :participating_users
  has_many :participants, through: :participating_users, source: :user
  
  validates :participating_users, presence: true


  validates :name, :description, presence:true
  validates :name, uniqueness: { case_insensitive: false }
  validate :due_date_validity
  validate :uniqueness_participant

  def uniqueness_participant
    users = participating_users.map{|p| p[:user_id] }
    return if users.uniq.length == users.length
    errors.add :base, I18n.t('task.errors.repeated_participant')
  end

  accepts_nested_attributes_for :participating_users, allow_destroy: true

  def due_date_validity
    return if due_date.blank?
    return if due_date > Date.today
    errors.add :due_date, I18n.t('tasks.errors.invalid_due_date')
  end
end
