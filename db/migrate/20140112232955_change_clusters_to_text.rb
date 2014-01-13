class ChangeClustersToText < ActiveRecord::Migration
  def change
	remove_column :courses, :clusters, :string
	add_column :courses, :clusters, :text

  	remove_column :courses, :prereqs, :string
    add_column :courses, :prereqs, :text

	remove_column :courses, :cross_listed, :string
    add_column :courses, :cross_listed, :text    

	remove_column :courses, :comments, :string
    add_column :courses, :comments, :text    

  	remove_column :tickets, :contents, :string
    add_column :tickets, :contents, :text
  end
end
