require 'csv'

qbil = CSV.read("../csv/qbil1_23_20.csv")
@array = []

def runner(qbil)
  qbil = convert_to_hash(qbil)
  parse_list(qbil)
  # duplicates(qbil)
end

# def duplicates(qbil)
#   b = @array.group_by {|x| x["MPN"]}.reject{|k,v|v.count == 1}.keys
#   b.each do |item|
#     qbil.each do |qb_item|

# end

def parse_list(qbil)
  qbil.each do |item|
    @array << item
  end
end

def convert_to_hash(file)
  array = []
  file.each do |line|
    array << Hash[file[0].zip(line.map)]
  end
  return array
end

runner(qbil)

b = @array.group_by {|x| x["MPN"]}.reject{|k,v|v.count == 1}.keys
b.each do |item|
  qbil.each do |qb_item|
    if item == qb_item["MPN"]
      p qb_item["MPN"]
    end
  end
end

