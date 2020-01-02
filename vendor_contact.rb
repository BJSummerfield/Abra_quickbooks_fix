require 'csv'

nf = CSV.read("../csv/nf_vendor.csv", :encoding => 'windows-1251:utf-8')
list = CSV.read("../csv/vendor_contact.csv", :encoding => 'windows-1251:utf-8')

@new_list = []

def runner(nf, list)
  nf = convert_to_hash(nf)
  list = convert_to_hash(list)
  file_match(nf, list)
  write_file(list)
end

def file_match(nf,list)
  nf.each do |nf_vendor|
    nf_vendor["Vendor"]
    parse_old_list(nf_vendor["Vendor"], list)
  end
end

def parse_old_list(nf_vendor, list)
  list.each do |old_customer|
    if nf_vendor == old_customer["Vendor"]
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
  CSV.open("../csv/updated_vendor_list.csv", "wb") do |csv|
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
