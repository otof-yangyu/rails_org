class RailsOrgInit < ActiveRecord::Migration[6.0]

  def change

    create_table :organs do |t|
      t.references :area
      t.references :parent
      t.string :name
      t.string :intro
      t.string :organ_uuid
      t.integer :limit_wechat
      t.string :address
      t.string :timezone
      t.string :locale
      t.integer :members_count, default: 0
      t.timestamps
    end

    create_table :organ_hierarchies, id: false do |t|
      t.integer :ancestor_id, null: false
      t.integer :descendant_id, null: false
      t.integer :generations, null: false
      t.index [:ancestor_id, :descendant_id, :generations], unique: true, name: 'organ_anc_desc_idx'
      t.index [:descendant_id], name: 'organ_desc_idx'
    end

    create_table :organ_grants do |t|
      t.references :organ
      t.references :user
      t.references :member
      t.string :token
      t.datetime :expire_at
      t.timestamps
    end

    create_table :departments do |t|
      t.references :organ
      t.references :parent
      t.references :superior
      t.string :name
      t.integer :member_departments_count
      t.integer :all_member_departments_count
      t.integer :needed_number
      if connection.adapter_name == 'PostgreSQL'
        t.jsonb :parent_ancestors
        t.jsonb :superior_ancestors
      else
        t.json :parent_ancestors
        t.json :superior_ancestors
      end
      t.timestamps
    end

    create_table :department_hierarchies, id: false do |t|
      t.integer :ancestor_id, null: false
      t.integer :descendant_id, null: false
      t.integer :generations, null: false
      t.index [:ancestor_id, :descendant_id, :generations], unique: true, name: 'department_anc_desc_idx'
      t.index [:descendant_id], name: 'department_desc_idx'
    end

    create_table :members do |t|
      t.references :user
      t.references :organ
      t.references :organ_root
      t.string :name
      t.string :identity
      t.string :number
      t.date :join_on
      t.boolean :enabled, default: true
      t.string :state
      t.boolean :owner
      t.timestamps
    end

    create_table :tutorials do |t|
      t.references :member
      t.references :tutor
      t.string :kind
      t.string :state
      t.string :accepted_status
      t.string :verified
      t.date :start_on
      t.date :finish_on
      t.string :performance
      t.integer :allowance
      t.string :note, limit: 4096
      t.string :comment, limit: 4096
      t.timestamps
    end

    create_table :job_titles do |t|
      t.references :organ
      t.references :department
      t.references :department_root
      t.string :type
      t.string :name
      t.string :description
      t.integer :grade
      t.integer :limit_number
      t.integer :cached_role_ids, array: true
      t.timestamps
    end

    create_table :job_title_references do |t|
      t.references :super_job_title
      t.references :department_root
      t.references :department
      t.integer :grade
      t.timestamps
    end

    create_table :member_departments do |t|
      t.references :member
      t.references :job_title
      t.references :department_root
      t.references :department
      t.references :superior
      t.integer :grade
      t.boolean :major
      t.integer :department_ids, array: true
      if connection.adapter_name == 'PostgreSQL'
        t.jsonb :department_ancestors
      else
        t.json :department_ancestors
      end
      t.timestamps
    end

    create_table :supports do |t|
      t.references :department
      t.references :office
      t.references :member
      t.string :name
      t.integer :grade
      t.string :code
      t.timestamps
    end

    create_table :organ_handles do |t|
      t.string :record_class
      t.string :record_column
      t.timestamps
    end

    create_table :department_grants do |t|
      t.references :organ
      t.references :organ_handle
      t.references :department
      t.references :job_title
      t.timestamps
    end

  end

end
