class Member < ApplicationRecord
  include RailsRoleUser
  include RailsTradeBuyer
  include RailsTradeUser
  include RailsNoticeReceivable

  has_taxons :department

  belongs_to :user, optional: true
  belongs_to :office, optional: true, counter_cache: true
  belongs_to :department, optional: true, counter_cache: true
  belongs_to :organ, optional: true

  has_one :organ_token, ->(o){ valid.where(organ_id: o.organ_id) }, foreign_key: :member_id
  has_many :organ_tokens, ->(o){ where(organ_id: o.organ_id) }, foreign_key: :member_id, dependent: :delete_all

  has_one :resign
  has_one :profile, through: :user
  has_one :tutorial, ->{ order(created_at: :desc) }, dependent: :nullify
  has_one :tutor, through: :tutorial
  has_one :leading_office, class_name: 'Office', foreign_key: :leader_id
  has_one :leading_department, class_name: 'Department', foreign_key: :leader_id
  has_many :leading_departments, class_name: 'Department', foreign_key: :leader_id

  has_many :tutorials, dependent: :nullify
  has_many :tutorings, class_name: 'Tutorial', foreign_key: :tutor_id
  has_many :tutees, through: :tutorings, source: :member
  has_many :job_transfers, dependent: :destroy

  validates :user_id, uniqueness: true, allow_blank: true

  #before_save :sync_tutorials, if: -> { join_on_changed? }

  def get_organ_token
    unless organ_token
      self.organ_tokens.delete_all
      create_organ_token
    end

    organ_token.token
  end

  def leading_section_members
    if leading_section
      Member.where(department_id: leading_section.self_and_descendant_ids, enabled: true)
    end
  end

  def leading_group_members
    if leading_group
      Member.where(department_id: leading_group.id, enabled: true)
    end
  end

  def leading_highest_department
    leading_departments = self.leading_departments
    unless leading_departments.empty?
      leading_departments = self.leading_departments.sort_by {|a| a.depth}
    end
    leading_departments.first
  end

  def timezone
    user.timezone || office.timezone || 'Beijing'
  end

  def locale
    user.locale || office.locale.presence || I18n.default_locale
  end

  def endearing_name
    name.split(/\s+/).first
  end

end
