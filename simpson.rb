require 'csv'
@i = 0
@m = 0
@e = 0
@array = []


mfg = CSV.read("../csv/simpson.csv")
qbil = CSV.read("../csv/qbil1_23_20.csv")

def runner(mfg, qbil)
  mfg = convert_to_hash(mfg)
  qbil = convert_to_hash(qbil)
  parse_mpn(mfg, qbil)
  write_file(qbil, @array)
  message
end

def write_file(qbil, ary)
  CSV.open("../csv/simpson_edit.csv", "wb") do |csv|
    input = []
    qbil[0].each do |k,v|
      input << k
    end
    csv << input
    ary.each do |item|
      input = []
      item.each do |k,v|
        input << v
      end
      csv << input
    end
  end
end

def parse_mpn(mfg, qbil)
  mfg.each do |mfg_item|
    if mfg_item["MPN"] != nil
      @i += 1
      parse_qbin(mfg_item, qbil)
    end
  end
end

def parse_qbin(mfg_item, qbil)
  qbil.each do |qb_item|
    if qb_item['MPN'] != "MPN"
      if qb_item["MPN"] == mfg_item['MPN']
        @m += 1
        compare_items(mfg_item, qb_item)
      end
    end
  end
end

def compare_items(mfg_item, qb_item)
  correct_price(mfg_item, qb_item)
  correct_desc(mfg_item, qb_item)
  @array << qb_item
end

def correct_desc(mfg_item, qb_item)
  pack = unit_Qty(mfg_item)
  qb_item['Unit Qty'] = pack
  qb_item['Weight'] = calculate_Weight(mfg_item, pack)
  # p "PackSize  :  Weight"
  # p "#{qb_item["Unit Qty"]}   :   #{qb_item["Weight"]}"
  # p "****************"
  return qb_item
end

def unit_Qty(mfg_item)
  exempt = ['ET-HP', 'EDOT', 'AT-XP', 'SET-XP', 'ATS', 'ETS']
  exempt.each do |exempt_item|
    if mfg_item["MPN"].include?(exempt_item)
      return 1
    end
  end
  pack = mfg_item["Carton"].to_i
end

def calculate_Weight(mfg_item, pack)
  weight = mfg_item['Weight'].to_f / pack
  if weight <= 2
    weight += 0.2
  else
    weight += (weight * 4) / 100
  end
  return weight.round(4).to_s
end

def correct_price(mfg_item, qb_item)
  mfg_cost = mfg_item["Cost"].to_f.round(2)
  qb_cost = qb_item["Cost"]
  @e += 1
  margin = calculate_margin(qb_item, mfg_item)
  if margin == nil
    margin = input_margin(margin, mfg_item, mfg_cost)
  end
  qb_item['Cost'] = mfg_cost.round(4)
  if mfg_item['MAP'] && mfg_item["MAP"] != 'tool'
    qb_item['Price'] = mfg_item["MAP"]
  else
    qb_item['Price'] = ((mfg_cost / margin) * 1.00).round(4)
  end
  # p "#{mfg_item["MPN"]}"
  # p "Cost  :  Price  :  Margin"
  # p "#{qb_item['Cost']} : #{qb_item["Price"]} : #{margin}"
  return qb_item
end

def calculate_margin(qb_item, mfg_item)
  if mfg_item["MAP"]
    return 0.85
  else return 0.50
  end
end

def price_length(item)
  if item.include?('.')
    return item.split(".")[-1].length
  else
    return 0
  end
end

def match_decimal(num, i)
  i.times do
    num = num + "0"
  end
  return num
end

def calculate_qb_cost(qb_item)
  return (qb_item['Cost'].delete('.').to_i) * 100
end

def message
  p "*************************"
  p "-------------------------"
  p "Total items: #{@i}"
  p "Total matches: #{@m}"
  p "Total price edits: #{@e}"
end

def convert_to_hash(file)
  array = []
  file.each do |line|
    array << Hash[file[0].zip(line.map)]
  end
  return array
end

runner(mfg, qbil)
