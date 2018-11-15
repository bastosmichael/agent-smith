require "agent/smith/version"
require 'thor'
require 'progress'

module Agent
  module Smith
    class CLI < Thor
      desc "file_by_name [from_directory, to_directory]", "Move files from one directory to another while creating sub directories based on name"
      def file_by_name(from_directory, to_directory=nil)
        Dir.glob(File.join(from_directory, "**/*/", File::SEPARATOR)).push(from_directory).uniq.with_progress.each do |path|
          Dir.glob(File.join(path, "*")).with_progress.each do |file|
            puts file
          end
        end
      end
    end
  end
end
