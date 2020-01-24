require 'csv'

qbil = CSV.read('../csv/mkt_edit.csv')
wpil = CSV.read('../csv/wpil1_23_20.csv')

@m = 0
@array = []

def runner(qbil, wpil)
  qbil = convert_to_hash(qbil)
  wpil = convert_to_hash(wpil)
  parse_mpn(qbil, wpil)
  write_file(wpil)
end

def write_file(wpil)
  CSV.open("../csv/mkt_weights.csv", "wb") do |csv|
    input = []
    wpil[0].each do |k,v|
      input << k
    end
    csv << input
    @array.each do |item|
      input = []
      item.each do |k,v|
        input << v
      end
      csv << input
    end
  end
end

def parse_mpn(qbil, wpil)
  qbil.each do |qbitem|
    parse_wp(qbitem, wpil)
  end
end

def parse_wp(qbitem, wpil)
  check = false
  wpil.each do |wpitem|
    if qbitem['Item'].split(':')[1] == wpitem["SKU"] && wpitem['SKU'] != nil
      @m += 1
      check = true
      item_match(qbitem, wpitem)
      @array << wpitem
    end
  end
end

def item_match(qbitem, wpitem)
  wpitem['MPN'] = qbitem['MPN']
  wpitem['Regular price'] = qbitem['Price']
  wpitem['Meta: _wpm_gtn_code'] = qbitem['MPN']
  wpitem['Weight (lbs)'] = qbitem['Weight']
  wpitem['Meta: variation_group_of_quantity'] = qbitem['Unit Qty']
  description_edit(qbitem, wpitem)
  wpitem['Meta: min_max_rules'] = 'yes'
  wpitem['Meta: variation_minmax_do_not_count'] = 'no'
  wpitem["Meta: variation_minmax_cart_exclude"] = 'no'
  wpitem["Meta: variation_minmax_category_group_of_exclude"] = 'no'
end

def description_edit(qbitem, wpitem)
  if wpitem['Meta: variation_group_of_quantity'].to_i == 1
    desc = '<p>Sold Individually</p>'
  elsif wpitem['Meta: variation_group_of_quantity'].to_i > 1
    desc = "<p>Sold In Quantities of #{wpitem['Meta: variation_group_of_quantity']}</p>"
  else
    desc = nil
  end
  wpitem["Description"] = desc
end

def convert_to_hash(file)
  array = []
  file.each do |line|
    array << Hash[file[0].zip(line.map)]
  end
  return array
end

runner(qbil, wpil)
