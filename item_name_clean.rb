require "csv"

file = CSV.read('../csv/itemlist.csv', :encoding => 'windows-1251:utf-8')

def runner(file)
  list = convert_to_hash(file)
  parse(list)
  # p list[0]
  write_file(list)
end

def write_file(list)
  i = 0
  CSV.open("../csv/item_list_edit.csv", "wb") do |csv|
    list.each do |item|
      input = []
      if i == 0
        item.each do |k,v|
        input << k
        end
      else
        item.each do |k,v|
          input << v
        end
      end
      i += 1
      csv << input
    end
  end
end

def parse(list)
  list.each do |item|
    if item["Description"]
      if item["Description"].include?('В”')
        item["Description"] = item["Description"].gsub('В”', '"')
        item["Purchase Description"] = item["Purchase Description"].gsub('В”', '"')
      end
    end
    if item["Description"]
      if item["Description"].include?('""')
        item["Description"] = item["Description"].delete_prefix('"').delete_suffix('"')
      end
    end
    if item["Purchase Description"]
      if item["Purchase Description"].include?('""')
        item["Purchase Description"] = item["Purchase Description"].delete_prefix('"').delete_suffix('"')
      end
    end
  end
end

def convert_to_hash(file)
  array = []
  file.each do |line|
    array << Hash[file[0].zip(line.map)]
  end
  return array
end

runner(file)

# someStr = 'He said "Hello, my name is Foo"';
# puts someStr.gsub("\"", "")
