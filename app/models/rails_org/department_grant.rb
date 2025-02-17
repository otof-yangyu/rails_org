module RailsOrg::DepartmentGrant
  extend ActiveSupport::Concern
  included do
    belongs_to :organ_handle
    belongs_to :department, optional: true
    belongs_to :job_title, optional: true
  end
  
end
