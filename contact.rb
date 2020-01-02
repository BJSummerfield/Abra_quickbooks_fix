require 'csv'

nf = CSV.read("../csv/nf_customer.csv", :encoding => 'windows-1251:utf-8')
list = CSV.read("../csv/customer_contact.csv", :encoding => 'windows-1251:utf-8')

@new_list = []

def runner(nf, list)
  nf = convert_to_hash(nf)
  list = convert_to_hash(list)
  file_match(nf, list)
  # write_file(list)
end

def file_match(nf,list)
  nf.each do |nf_customer|
    nf_customer["Customer"]
    parse_old_list(nf_customer["Customer"], list)
  end
end

def parse_old_list(nf_customer, list)
  list.each do |old_customer|
    if nf_customer == old_customer["Customer"]
      @new_list << old_customer
      return
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

def write_file(list)
  CSV.open("../csv/updated_contact_list.csv", "wb") do |csv|
    input = []
    list[0].each do |k,v|
      input << k
    end
    csv << input
    @new_list.each do |item|
      input = []
      item.each do |k,v|
        input << v
      end
      csv << input
    end
  end
end




runner(nf, list)
