class CreateTaskManagerCore < ActiveRecord::Migration[8.1]
  def change
    create_table :plans do |t|
      t.string :name, null: false
      t.decimal :price, precision: 10, scale: 2, null: false, default: 0
      t.integer :user_limit, null: false
      t.integer :project_limit, null: false
      t.boolean :discount_active, null: false, default: false
      t.decimal :discount_percentage, precision: 5, scale: 2, null: false, default: 0
      t.timestamps
    end
    add_index :plans, :name, unique: true

    create_table :organizations do |t|
      t.string :name, null: false
      t.string :segment
      t.text :description
      t.references :plan, null: false, foreign_key: true
      t.timestamps
    end

    create_table :users do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :username
      t.string :role, null: false, default: "standard"
      t.string :password_digest, null: false
      t.timestamps
    end
    add_index :users, :email, unique: true
    add_index :users, :username, unique: true, where: "username IS NOT NULL"

    create_table :projects do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.timestamps
    end
    add_index :projects, [ :organization_id, :name ]

    create_table :project_memberships do |t|
      t.references :project, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
    add_index :project_memberships, [ :project_id, :user_id ], unique: true

    create_table :statuses do |t|
      t.references :project, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :position, null: false
      t.boolean :active, null: false, default: true
      t.timestamps
    end
    add_index :statuses, [ :project_id, :position ]

    create_table :tasks do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :project, null: false, foreign_key: true
      t.references :status, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.decimal :story_points, precision: 8, scale: 1
      t.date :due_date
      t.timestamps
    end
    add_index :tasks, [ :organization_id, :status_id, :updated_at ]
    add_index :tasks, [ :project_id, :status_id, :updated_at ]
    add_check_constraint :tasks, "story_points IS NULL OR (story_points >= 0.1 AND story_points <= 999999.9)", name: "tasks_story_points_range"

    create_table :task_assignments do |t|
      t.references :task, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
    add_index :task_assignments, [ :task_id, :user_id ], unique: true

    create_table :comments do |t|
      t.references :task, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :body, null: false
      t.timestamps
    end
    add_index :comments, [ :task_id, :created_at ]

    create_table :active_storage_blobs do |t|
      t.string :key, null: false
      t.string :filename, null: false
      t.string :content_type
      t.string :metadata
      t.string :service_name, null: false
      t.bigint :byte_size, null: false
      t.string :checksum
      t.datetime :last_verified_at
      t.datetime :created_at, null: false
      t.index [ :key ], unique: true
    end

    create_table :active_storage_attachments do |t|
      t.string :name, null: false
      t.references :record, null: false, polymorphic: true, index: false
      t.references :blob, null: false, foreign_key: { to_table: :active_storage_blobs }
      t.datetime :created_at, null: false
      t.index [ :record_type, :record_id, :name, :blob_id ], unique: true, name: "index_active_storage_attachments_uniqueness"
    end

    create_table :active_storage_variant_records do |t|
      t.belongs_to :blob, null: false, index: false, foreign_key: { to_table: :active_storage_blobs }
      t.string :variation_digest, null: false
      t.index [ :blob_id, :variation_digest ], unique: true
    end
  end
end
