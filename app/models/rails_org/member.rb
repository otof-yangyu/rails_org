module RailsOrg::Member
  extend ActiveSupport::Concern
  included do
    delegate :url_helpers, to: 'Rails.application.routes'
    has_taxons :department

    attribute :experience, :string
    attribute :attendance_number, :string

    belongs_to :user, optional: true
    belongs_to :account, -> { where(confirmed: true) }, primary_key: :identity, foreign_key: :identity, optional: true
    belongs_to :profile, ->(o){ where(organ_id: o.organ_id, user_id: o.user_id) }, primary_key: :identity, foreign_key: :identity, optional: true
    belongs_to :organ

    has_many :member_departments, dependent: :delete_all
    has_many :departments, through: :member_departments
    has_many :job_titles, through: :member_departments
    accepts_nested_attributes_for :member_departments
    
    has_many :leading_departments, class_name: 'Department', foreign_key: :leader_id
    
    has_many :organ_grants, dependent: :delete_all

    has_one :resign
    has_one :tutorial, ->{ order(created_at: :desc) }, dependent: :nullify
    has_one :tutor, through: :tutorial
    has_many :tutorials, dependent: :nullify
    has_many :tutorings, class_name: 'Tutorial', foreign_key: :tutor_id
    has_many :tutees, through: :tutorings, source: :member
    #has_many :job_transfers, dependent: :destroy

    has_one_attached :avatar
    has_one_attached :resume
    
    scope :enabled, -> { where(enabled: true) }
    
    validates :identity, uniqueness: { scope: :organ_id }
    #before_save :sync_tutorials, if: -> { join_on_changed? }
    before_save :sync_account_user, if: -> { identity_changed? }
    after_create :sync_member_roles, if: -> { organ.creator_id.present? && organ.creator_id == user_id }
  end

  def sync_account_user
    self.user_id = account&.user_id
  end

  def init_user
    account || build_account
    account.user || account.build_user
    self.user = account.user
  
    self.class.transaction do
      self.save!
      account.save!
    end
  
    user
  end

  def direct_follower_ids
    return @direct_follower_ids if defined?(@direct_follower_ids)
    direct_ids = member_departments.map do |md|
      md.direct_followers.pluck(:member_id)
    end
    direct_ids << self.id
    @direct_follower_ids = direct_ids.flatten.uniq
  end

  def direct_followers
    Member.where(id: direct_follower_ids)
  end

  def all_follower_ids
    return @all_follower_ids if defined?(@all_follower_ids)
    all_ids = member_departments.map do |md|
      md.all_followers.pluck(:member_id)
    end
    all_ids << self.id
    @all_follower_ids = all_ids.flatten.uniq
  end

  def all_followers
    Member.where(id: all_follower_ids)
  end
  
  def leader
  
  end
  
  def get_organ_grant
    grant = self.organ_grants.find_or_create_by(organ_id: self.organ_id)
    unless grant.valid_period?
      grant.update_token!
    end
    grant
  end

  def leading_members
    Member.where(department_id: leading_department.self_and_descendant_ids)
  end

  def leading_member_ids
    leading_members.pluck(:id)
  end

  def leading_highest_department
    leading_departments = self.leading_departments
    unless leading_departments.empty?
      leading_departments = self.leading_departments.sort_by(&:depth)
    end
    leading_departments.first
  end

  def timezone
    user.timezone || office.timezone || 'Beijing'
  end

  def locale
    user.locale || office.locale.presence || I18n.default_locale
  end

  def avatar_url
    url_helpers.rails_blob_url(avatar) if avatar.attachment.present?
  end

  def sync_member_roles
    role = Role.default_where('who_types-any': 'Member', code: RailsOrg.config.super_role_code).take
    who_roles.create(role_id: role.id) if role
  end

end
