require 'csv'



products = CSV.read("../csv/non_active.csv")

def runner(products)
  nl = []
  products = convert_to_hash(products)
  inactive_screen(products, nl)
  write_file(nl, products)
  p nl
end

def inactive_screen(products, nl)
  products.each do |item|
    if item['Active Status'] == "Active"
      nl << item
    end
  end
end

def write_file(nl, products)
  CSV.open("../csv/active.csv", "wb") do |csv|
    input = []
    products[0].each do |k,v|
      input << k
    end
    csv << input
    nl.each do |item|
      input = []
      item.each do |k,v|
        input << v
      end
      csv << input
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

runner(products)


