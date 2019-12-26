require 'csv'


yoy = CSV.read("../csv/yoy.csv")
leads = CSV.read("../csv/leads.csv")
oicl = CSV.read("../csv/oicl.csv")

def runner(leads)
  nl = []
  total = {'total' => 0, 'match' => 0}
  list = convert_to_hash(leads)
  state_search(nl, list, total)
  write_file(nl, leads)
  p nl
  p total
end

def state_search(nl, list, total)
  list.each do |item|
    total['total'] += 1
    a = check_state(item,total)
    item['State'] = a
    p "#{item["Customer"]} - #{item['State']}"
    nl << item
  end
end

def check_state(item, total)
  5.times do |i|
    @state_array.each do |state|
      if item["Bill to #{i + 1}"] != nil && item["Bill to #{i + 1}"].include?(" #{state}")
        total['match'] += 1
        return state
      end
    end
  end
  return nil
end


def write_file(nl, leads)
  CSV.open("../csv/state_added.csv", "wb") do |csv|
    input = []
    leads[0].each do |k,v|
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

@state_array = [
"AL",
"AK",
"AZ",
"AR",
"CA",
"CO",
"CT",
"DE",
"FL",
"GA",
"HI",
"ID",
"IL",
"IN",
"IA",
"KS",
"KY",
"LA",
"ME",
"MD",
"MA",
"MI",
"MN",
"MS",
"MO",
"MT",
"NE",
"NV",
"NH",
"NJ",
"NM",
"NY",
"NC",
"ND",
"OH",
"OK",
"OR",
"PA",
"RI",
"SC",
"SD",
"TN",
"TX",
"UT",
"VT",
"VA",
"WA",
"WV",
"WI",
"WY",
"AS",
"DC",
"FM",
"GU",
"MH",
"MP",
"PW",
"PR",
"VI"
]

runner(leads)
