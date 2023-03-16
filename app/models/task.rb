class Task < ApplicationRecord
  belongs_to :category
  belongs_to :owner, class_name: 'User'
  has_many :participating_users, class_name: 'Participant'
  has_many :participants, through: :participating_users, source: :user
  has_many :notes
  validates :participating_users, presence: true


  validates :name, :description, presence:true
  validates :name, uniqueness: { case_insensitive: false }
  validate :due_date_validity

  before_create :create_code
  after_create :send_email

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

  def create_code
    self.code = "#{owner_id}#{Time.now.to_i.to_s(36)}#{SecureRandom.hex(8)}"
  end
  def send_email
    (participants + [owner]).each do |user|
      ParticipantMailer.with(user: user, task: self).new_task_email.deliver!
    end
  end
end

