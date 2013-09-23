class AddCustomPayloadsToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :custom_payloads, :text
  end
end
