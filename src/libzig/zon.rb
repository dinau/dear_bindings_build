def make_depname_json()
  output_file = "dep_ist.json"
  File.open(output_file, "w") do |file|
    str =  ".dependencies = .{"
    puts str
    file.puts str
    Dir.entries('.').each do |entry|
      next if entry == '.' || entry == '..'
      if File.directory?(entry)
        str = "    .#{entry} = .{\n        .path = \"../#{entry}\",\n    },"

        puts str # 表示
        file.puts(str )
      end
    end
    str = "},"
    puts str
    file.puts(str)
  end
end

make_depname_json()

def make_lib_names_zig()
  output_file = "mod_list.zig"
  File.open(output_file, "w") do |file|
    str =  "pub const lib_names = [_][]const u8{\n"
    puts str
    file.puts str
    Dir.entries('.').each do |entry|
      next if entry == '.' || entry == '..'
      if File.directory?(entry)
        str = "    \"#{entry}\","

        puts str #
        file.puts(str )
      end
    end
    str = "};"
    puts str
    file.puts(str)
  end
end
