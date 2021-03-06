module Frank
  module Publish

    class SCP
      def self.execute!
        puts "\nFrank is..."
        puts " - \033[32mExporting templates\033[0m"

        tmp_folder = "/tmp/frankexp-#{Frank.proj_name}"

        # remove stale folder if it exists
        FileUtils.rm_rf(tmp_folder) if File.exist?(tmp_folder)

        # dump the project in production mode to tmp folder
        Frank.export.path = tmp_folder
        Frank.export.silent = true
        Frank::Compile.export!

        puts " - \033[32mPublishing to:\033[0m `#{Frank.publish.host}:#{Frank.publish.path}'"

        ssh_options = {
          :password => Frank.publish.password,
          :port     => Frank.publish.port
        }

        current = nil

        # upload the files and report progress
        Net::SSH.start(Frank.publish.host, Frank.publish.user, ssh_options) do |ssh|
          ssh.scp.upload!(tmp_folder, Frank.publish.path, :recursive => true, :chunk_size => 2048) do |ch, name, sent, total|

            puts "   - #{name[tmp_folder.length..-1]}" unless name == current

            current = name
          end
        end

        # cleanup by removing tmp folder
        FileUtils.rm_rf(tmp_folder)

        puts "\n\033[32mPublish complete!\033[0m"
      end
    end

  end
end