require "agent/smith/version"
require 'thor'
require 'progress'

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
    end
  end
end
