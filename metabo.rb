require 'csv'

mfg = CSV.read("../csv/metabo.csv")
qbil = CSV.read("../csv/itemlist116.csv")

def runner(mfg, qbil)
  i = 0
  j = 0
  fixed_items = []
  mfg = convert_to_hash(mfg)
  qbil = convert_to_hash(qbil)
  mfg.each do |mfg_item|
    if mfg_item['MPN'] != nil
      items = pn_match(mfg_item, qbil)
      if items != nil
        j += 1
        qb_item = items[0]
        mfg_item = items[1]
        if qb_item['Cost'] != mfg_item['Cost']
          puts ""
          p qb_item["Item"]
          p "Cost  -  Sell"
          p "#{qb_item['Cost']} - #{qb_item['Price']}"
          margin = get_margin(qb_item['Cost'], qb_item['Price'])
          p "margin = #{margin}"
          if mfg_item['MAP'] != nil
            check_map(qb_item, mfg_item)
            p "Using Map Pricing"
            i += 1
          elsif
            cost_fix(margin, qb_item, mfg_item)
            i += 1
          end
          p "Fix"
          p "#{qb_item['Cost']} - #{qb_item['Price']}"
          fixed_items << qb_item
        end
      end
    end
  end
  write_file(fixed_items, qbil)
  puts "#{j} Matches"
  puts "#{i} Total Edits"
end

def write_file(ary, qbil)
  CSV.open("../csv/metabo_edit.csv", "wb") do |csv|
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

def check_map(qb_item, mfg_item)
  qb_item['Cost'] = mfg_item["Cost"]
  qb_item["Price"] = mfg_item['MAP']
end

def get_margin(cost, price)
  cost = decimal_fix(cost)
  price = decimal_fix(price)
  if cost[1] != nil || price[1] != nil
    match_decimal(cost, price)
  end
  return (cost.join.to_i * 100.00) / price.join.to_i
end

def match_decimal(cost, price)
  if price[1] == nil
    add_zeros(price, cost[1].to_s.length)
  elsif cost[1] == nil
    add_zeros(cost, price[1].to_s.length)
  elsif price[1].to_s.length > cost[1].to_s.length
    add_zeros(cost, price[1].to_s.length - cost[1].to_s.length)
  elsif price[1].to_s.length < cost[1].to_s.length
    add_zeros(price, cost[1].to_s.length - price[1].to_s.length)
  end
end

def add_zeros(item, number)
  if item[1] == nil
    item[1] = "0"
    number -= 1
  end
  item[1] = item[1].to_s
  number.times do
    item[1] << "0"
  end
end

def decimal_fix(string)
  num = string.split(".").map{ |e| e.to_i}
end

def cost_fix(margin, qb_item, mfg_item)
  qb_item['Cost'] = mfg_item['Cost']
  cost = decimal_fix(qb_item['Cost'])
  length = cost[1].to_s.length
  qb_item['Price'] = '%.2f' % ((cost.join.to_i / (margin / 100.00)) / 10**length).to_s
end

def pn_match(mfg_item, qbil)
  qbil.each do |qb_item|
    if qb_item["MPN"] != nil
      if qb_item['MPN'] == mfg_item['MPN']
        return [qb_item, mfg_item]
      end
    end
  end
  return nil
end


def convert_to_hash(file)
  array = []
  file.each do |line|
    array << Hash[file[0].zip(line.map)]
  end
  return array
end

runner(mfg, qbil)
