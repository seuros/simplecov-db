# frozen_string_literal: true

require 'fileutils'
require 'pathname'
require 'active_record'
require 'sqlite3'
require 'simplecov'
require_relative 'simplecov/db/version'

module SimpleCov
  module Formatter
    class DBFormatter
      class ApplicationRecord < ActiveRecord::Base
        self.abstract_class = true
        establish_connection(
          adapter: 'sqlite3',
          database: "#{SimpleCov.coverage_path}/coverage.sqlite3"
        )
      end

      class Run < ApplicationRecord
        has_many :groups
        has_many :results
      end

      class Group < ApplicationRecord
        belongs_to :run
        has_many :results
      end

      class Result < ApplicationRecord
        belongs_to :run
        belongs_to :group

        before_save :set_run_id

        def set_run_id
          self.run_id = group.run_id
        end
      end

      def format(result)
        create_coverage_table
        create_groups(create_run(result), result.groups)
      end

      private

      def create_coverage_table
        return true if ApplicationRecord.connection.table_exists?(:results)

        Run.connection.create_table :runs do |t|
          t.string :command_name, null: false
          t.integer :seed, null: false
          t.string :branch_name, null: false
          t.datetime :created_at, null: false
          t.float :covered_percent, null: false
          t.float :covered_strength, null: false
          t.integer :covered_lines, null: false
          t.integer :missed_lines, null: false
          t.integer :total_branches
          t.integer :covered_branches
          t.integer :missed_branches
          t.integer :total_lines, null: false
        end

        Group.connection.create_table :groups do |t|
          t.string :name, null: false
          t.integer :run_id, null: false
          t.integer :lines_covered
          t.integer :never_lines
          t.integer :skipped_lines
          t.integer :lines_total
          t.integer :branches_covered
          t.integer :branches_total
          t.integer :covered_branches
          t.integer :missed_branches
          t.float :covered_percent
          t.float :branch_covered_percent
        end

        # SimpleCov::SourceFile
        Result.connection.create_table :results do |t|
          t.integer :run_id, null: false
          t.string :group_id, null: false
          t.string :filename, null: false
          t.integer :covered_lines, null: false
          t.integer :missed_lines, null: false
          t.integer :never_lines, null: false
          t.integer :lines_of_code, null: false
          t.float :covered_percent, null: false
          t.float :covered_strength, null: false
        end
        true
      end

      def create_run(result)
        data = {
          created_at: result.created_at,
          command_name: result.command_name,
          seed: Minitest.seed,
          covered_percent: result.covered_percent,
          covered_strength: result.covered_strength,
          covered_lines: result.covered_lines,
          missed_lines: result.missed_lines,
          total_branches: result.total_branches,
          covered_branches: result.covered_branches,
          missed_branches: result.missed_branches,
          total_lines: result.total_lines,
          branch_name: `git rev-parse --abbrev-ref HEAD`
        }

        Run.create!(data)
      end

      def create_groups(run, groups)
        groups.each do |group|
          generate_lcov_report_for_group(run, group)
        end
      end

      def prepare_group_data(group_name, file_list)
        {
          name: group_name,
          lines_covered: file_list.covered_lines,
          never_lines: file_list.never_lines,
          skipped_lines: file_list.skipped_lines,
          lines_total: file_list.lines_of_code,
          branches_covered: file_list.covered_branches,
          branches_total: file_list.total_branches,
          covered_branches: file_list.covered_branches,
          missed_branches: file_list.missed_branches,
          covered_percent: file_list.covered_percent,
          branch_covered_percent: file_list.branch_covered_percent
        }
      end

      def generate_lcov_report_for_group(run, group)
        group_name = group.first
        file_list = group.last
        group_record = run.groups.create!(prepare_group_data(group_name, file_list))
        generate_lcov_report(group_record, file_list)
      end

      def generate_lcov_report(group_record, files)
        files.each do |file|
          group_record.results.create!(
            format_file(file)
          )
        end
      end

      def format_file(file)
        {
          filename: file.project_filename,
          covered_lines: file.covered_lines.count,
          missed_lines: file.missed_lines.count,
          never_lines: file.never_lines.count,
          lines_of_code: file.lines_of_code,
          covered_percent: file.covered_percent,
          covered_strength: file.covered_strength
        }
      end
    end
  end
end
