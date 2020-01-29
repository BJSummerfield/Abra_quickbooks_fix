require 'mechanize'
require 'nokogiri'
require 'csv'

@items = []


browser = Mechanize.new { |agent|
  agent.user_agent_alias = 'Mac Safari'
}

def runner(browser)
  un = get_info('Username')
  pass = get_info('Password')
  login(browser, un, pass)
  item_list = get_item_list
  item_list.each do |item|
    puts "Getting Simpson Data for #{item}"
    get_item(browser, item)
  end
  write_file
end

def get_info(name)
  puts "Enter your #{name}:"
  return gets.chop
end

def get_item_list
  array = []
  list = CSV.read('./csv/simpson.csv')
  list.each do |row|
    if row[0] == 'MPN'
    else
      array << row[0]
    end
  end
  return array
end

def write_file
  CSV.open('./simpsonPrice.csv', 'wb') do |csv|
    input = []
    @items[0][0].each do |k,v|
      input << k
    end
    csv << input
    i = 0
    @items.each do |item|
      input = []
      item[0].each do |k,v|
        input << v
      end
      csv << input
    end
  end
end

def login(browser, un, pass)
  browser.get('https://ordering.strongtie.com/OPPAv2/Account/Login') do |page|
    form = page.forms.last
    form.User = un
    form.Password = pass
    login = browser.submit(form, form.buttons.first)
  end
end

def get_item(browser, item)
  browser.get("https://ordering.strongtie.com/OPPAv2/Item/InquiryM?item=#{item}") do |page|
    table = page.at('.pricing-table')
    array = []
  if table != nil
      table.search('tr').each do |tr|
        ar = []
        cells = tr.search('th, td')
          cells.each do |cell|
          ar << cell.text.strip
        end
        array << ar
      end
      item = convert_to_hash(array, item)
      @items << item
    end
  end
end

def convert_to_hash(web_item, item)
  web_item[0].unshift("MPN")
  web_item[1].unshift(item)
  array = []
  array << Hash[web_item[0].zip(web_item[1].map)]
  return array
end

runner(browser)
