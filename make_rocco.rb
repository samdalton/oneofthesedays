input_dir = '_rocco'
output_dir = '_posts'
template = '_layouts/rocco.mustache'

Dir.foreach('_rocco') do |file|
    unless File.directory?(file) or file =~ /(\.swp|DS_Store|.swo|archive)/
        puts 'Found ' + file
        %x{rocco #{input_dir}/#{file} -o #{output_dir} -t #{template} }
        
        # the output file now exists at output_dir/input_dir/file_name.html
        # so let's move it up to the _posts folder
        new_file = file.gsub(/\.[a-z]+$/, '.html')
        %x{ mv #{output_dir}/#{input_dir}/#{new_file} #{output_dir} }
    
        # add desired header to new post
        %x{ echo "---\nlayout: post\n---"|cat - #{output_dir}/#{new_file} > /tmp/out && mv /tmp/out #{output_dir}/#{new_file}  }

        # clean up by removing this unwanted dir
        %x{ rm -rf #{output_dir}/#{input_dir} }
    end
end


