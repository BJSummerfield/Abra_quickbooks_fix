require 'csv'


yoy = CSV.read("../csv/yoy.csv")
customers = CSV.read("../csv/customers.csv")
oicl = CSV.read("../csv/oicl.csv")

def runner(yoy, customers, oicl)
  nl = []
  total = {'total' => 0, 'edit' => 0, 'match' => 0}
  yoy = convert_to_hash(yoy)
  customers = convert_to_hash(customers)
  match_customers(yoy, customers, total, nl, oicl)
  write_file(nl, customers)
  # p nl.length
  totals(total)
end

def write_file(nl, customers)
  CSV.open("../csv/new_list.csv", "wb") do |csv|
    input = []
    customers[0].each do |k,v|
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

def match_customers(yoy,customers,total, nl, oicl)
  customers.each do |customer|
    total['total'] += 1
    match_active_customer(yoy, customer, total, nl, oicl)
  end
end

def match_active_customer(yoy, customer, total, nl, oicl)
  yoy.each do |active_customer|
    if active_customer['Name'] == customer['Customer']
      total['match'] += 1
      if activity_check(active_customer, oicl)
        total['edit'] +=1
        nl << customer
      end
    end
  end
end

def activity_check(customer, oicl)
  if check_open_invoice(customer, oicl)
    return true
  else
    if customer['2018'].delete('.').to_i / 100.00 == 0.0 && customer['2019'].delete('.').to_i / 100.00 < 1000
      return false
    else
      return true
    end
  end
end

def check_open_invoice(customer, oicl)
  x = false
  oicl.each do |n|
    if n[0] == customer['Name']
      x = true
    end
  end
  return x
end

def totals(total)
  puts "Total Customers: #{total['total']}"
  puts "Total Matches : #{total['match']}"
  puts "Total Edits: #{total['edit']}"
end

def convert_to_hash(file)
  array = []
  file.each do |line|
    array << Hash[file[0].zip(line.map)]
  end
  return array
end

def count(list)
  i = 0
  list.each do |item|
    i += 1
  end
  p i
end
runner(yoy, customers, oicl)

