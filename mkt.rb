require 'csv'
@i = 0
@m = 0
@e = 0

mfg = CSV.read("../csv/mkt.csv")
qbil = CSV.read("../csv/qbil121819.csv")

# match qbil = MPN - mfg = Part No.
def runner(mfg, qbil)
  mfg = convert_to_hash(mfg)
  qbil = convert_to_hash(qbil)
  parse_mpn(mfg, qbil)
  message
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
  compare_price(mfg_item, qb_item)
end

def compare_price(mfg_item, qb_item)
  mfg_cost = calculate_mfg_cost(mfg_item)
  qb_cost = calculate_qb_cost(qb_item)
  # p "*************"
  # p "ps = #{mfg_cost}"
  # p "qb = #{qb_cost}"
  if mfg_cost == qb_cost
    # p "match"
  else
    @e += 1
    # p "#{qb_item['Cost']} - #{qb_item['Price']}"
    margin = calculate_margin(qb_item)
    p '****************************************'
    p '****************************************'
    p "QB Desc: #{qb_item['Description']}"
    p "QB Cost: #{qb_item['Cost']}, QB Sell #{qb_item['Price']}"
    if margin != 'No existing Margin'
      p "QB Margin: #{((margin - 1) * (-1)) * 100}%"
    else
      p "QB Margin: #{margin}"
    end
    p "----------------------------------------"
    p "MFG Desc: #{mfg_item['Description']}"
    p "MFG Unit Price: #{mfg_item['PRICE PER']}, MFG PackSize: #{mfg_item['INNER QTY']}, MFG Cost: #{mfg_item['Cost']}"
    p "MFG: Item Cost: #{mfg_cost / 100}"
    if margin != 'No existing Margin'
      p "New Sell: #{((mfg_cost / 100) / margin) * 1.00}"
    else
      p margin
    end
  end
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
      # i.times do
      #   qbp = qbp + "0"
      # end
    else pl > cl
      i = pl - cl
      qbc = match_decimal(qbc, i)
      # i.times do
      #   qbc = qbc + "0"
      # end
    end
    margin = (qbc.to_i * 1.00) / (qbp.to_i * 1.00)
    # IF STATEMENT FOR MARGIN SIZE HERE
    return (qbc.to_i * 1.00) / (qbp.to_i * 1.00)
  end
  return "No existing Margin"
end

def match_decimal(num, i)
  i.times do
    num = num + "0"
  end
  return num
end

def calculate_qb_cost(qb_item)
  return qb_item['Cost'].delete('.').to_i
end

def calculate_mfg_cost(mfg_item)
  mfg_unit_price = 1000.00 if mfg_item['PRICE PER'] == "M"
  mfg_unit_price = 100.00 if mfg_item['PRICE PER'] == "C"
  mfg_unit_price = 1.00 if mfg_item['PRICE PER'] == "EA"
  # p mfg_item['INNER QTY'].to_i / mfg_unit_price
  if mfg_item['Cost'].length > 1
    return (mfg_item['INNER QTY'].to_i / mfg_unit_price) * mfg_item['Cost'].delete(".").to_i
  else
    return ((mfg_item['INNER QTY'].to_i / mfg_unit_price) * mfg_item['Cost'].to_i) * 100
  end
end

def message
  p "*************************"
  p "-------------------------"
  p "Total items: #{@i}"
  p "Total matches: #{@m}"
  p "Total edits: #{@e}"
end



def convert_to_hash(file)
  array = []
  file.each do |line|
    array << Hash[file[0].zip(line.map)]
  end
  return array
end

runner(mfg, qbil)

