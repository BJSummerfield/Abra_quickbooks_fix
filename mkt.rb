require 'csv'
@i = 0
@m = 0
@e = 0
@array = []

mfg = CSV.read("../csv/mkt.csv")
qbil = CSV.read("../csv/qbil1_23_20.csv")

def runner(mfg, qbil)
  mfg = convert_to_hash(mfg)
  qbil = convert_to_hash(qbil)
  parse_mpn(mfg, qbil)
  write_file(qbil, @array)
  message
end

def write_file(qbil, ary)
  CSV.open("../csv/mkt_edit.csv", "wb") do |csv|
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
    @i += 1
    parse_qbin(mfg_item, qbil)
  end
end

def parse_qbin(mfg_item, qbil)
  qbil.each do |qb_item|
    if qb_item["MPN"] == mfg_item['Part No.']
      @m += 1
      compare_items(mfg_item, qb_item)
    end
  end
end

def compare_items(mfg_item, qb_item)
  correct_price(mfg_item, qb_item)
  correct_desc(mfg_item, qb_item)
  @array << qb_item
end

def correct_desc(mfg_item, qb_item)
  qb_item['Unit Qty'] = mfg_item['INNER QTY']
  qb_item['Weight'] = calculate_Weight(mfg_item)
  return qb_item
end

def calculate_Weight(mfg_item)
  weight = (mfg_item['Wt (lbs)'].to_f / mfg_item['INNER QTY'].to_f)
  if weight <= 2
    weight += 0.2
  else
    weight += (weight * 4) / 100
  end
  return weight.round(4).to_s
end

def correct_price(mfg_item, qb_item)
  mfg_cost = calculate_mfg_cost(mfg_item)
  qb_cost = qb_item["Cost"]
  # if mfg_cost.to_s == qb_cost.to_s
  # else
    @e += 1
    margin = 0.5 #calculate_margin(qb_item) if copying margins

    # if margin == nil
    #   margin = input_margin(margin, mfg_item, mfg_cost)
    # end
    qb_item['Cost'] = mfg_cost.round(4)
    qb_item['Price'] = ((mfg_cost / margin) * 1.00).round(4)
  # end
  return qb_item
end

def input_margin(margin, mfg_item, mfg_cost)
  puts "*************************"
  puts "No Margin Found"
  puts "-------------------------"
  puts "MFG Desc: #{mfg_item['Description']}"
  puts "MFG Unit Price: #{mfg_item['PRICE PER']}, MFG PackSize: #{mfg_item['INNER QTY']}, MFG Cost: #{mfg_item['Cost']}"
  puts "MFG: Item Cost: #{mfg_cost / 100}"
  puts "-------------------------"
  puts "Enter Desired Margin: ie - 25 = 25%"
  input = gets.chomp
  input = (((input.to_i / 100.00) - 1.00) * -1.00)
  return input
end

def calculate_margin(qb_item)
  if qb_item['Cost'].delete('.').to_i != 0 || qb_item['Price'].delete('.').to_i != 0
    qbc = qb_item["Cost"].delete('.')
    qbp = qb_item['Price'].delete('.')
    cl = qb_item['Cost'].split('.')[-1].length
    pl = qb_item['Price'].split('.')[-1].length
    if cl > pl
      i = cl - pl
       qbp = match_decimal(qbp, i)
    else pl > cl
      i = pl - cl
      qbc = match_decimal(qbc, i)
    end
    margin = (qbc.to_i * 1.00) / (qbp.to_i * 1.00)
    # IF STATEMENT FOR MARGIN SIZE HERE
    return (qbc.to_i * 1.00) / (qbp.to_i * 1.00)
  end
  return nil
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

def calculate_mfg_cost(mfg_item)
  mfg_unit_price = 1000.00 if mfg_item['PRICE PER'] == "M"
  mfg_unit_price = 100.00 if mfg_item['PRICE PER'] == "C"
  mfg_unit_price = 1.00 if mfg_item['PRICE PER'] == "EA"
  return mfg_item['Cost'].to_f / mfg_unit_price
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

