require "agent/smith/version"
require 'thor'
require 'progress'
require 'fileutils'
require 'smarter_csv'
require 'json'

module Agent
  module Smith
    class CLI < Thor
      desc "file_by_name [from_directory, to_directory]", "Move files from one directory to another while creating sub directories based on name"
      def file_by_name(from_directory=nil, to_directory=nil, directory_name_size=2)
        raise 'From Directory not included' unless from_directory
        raise 'To Directory not included' unless to_directory
        FileUtils.mkdir_p to_directory
        Dir.glob(File.join(from_directory, "**/*/", File::SEPARATOR)).push(from_directory).uniq.with_progress.each do |path|
          Dir.glob(File.join(path, "*")).with_progress.each do |file|
            if File.file?(file) && basename = File.basename(file, ".*")
              new_directory = [to_directory, basename.scan(/.{#{directory_name_size}}/).join('/')].join('/')
              FileUtils.mkdir_p new_directory
              new_file = [new_directory, File.basename(file)].join('/')
              FileUtils.cp_r file, new_file
            end
          end
        end
      end

      desc "csv_to_json [from_directory, to_directory, include_file_name]", "Create JSON files from CSV in one directory to another while creating sub directories based on file name"
      def csv_to_json(from_directory=nil, to_directory=nil, include_file_name = true)
        raise 'From Directory not included' unless from_directory
        raise 'To Directory not included' unless to_directory
        FileUtils.mkdir_p to_directory
        Dir.glob(File.join(from_directory, "**/*/", File::SEPARATOR)).uniq.with_progress.each do |path|
          relative_path = path.dup.tap{|s| s.slice!(from_directory)}
          Dir.glob(File.join(path, "*.csv")).with_progress.each do |file|
            if File.file?(file) && basename = File.basename(file, ".*")
              array_of_records = SmarterCSV.process(file).uniq
              next unless array_of_records.any?

              new_directory = include_file_name ? [to_directory, relative_path, basename].join : [to_directory, relative_path].join
              FileUtils.mkdir_p new_directory

              array_of_records.uniq.with_progress.each do |record|
                name = record[:hash].to_s + '.json'
                new_file = [new_directory, name].join('/')
                File.write(new_file, record.to_json)
              end
            end
          end
        end
      end
    end
  end
end
