require 'mechanize'
require 'json'

headers = {
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
    'Accept-Encoding': 'gzip, deflate, sdch',
    'Accept-Language': 'zh-CN,zh;q=0.8,en-US;q=0.6,en;q=0.4',
    'Cache-Control': 'max-age=0',
    'Connection': 'keep-alive',
    'Cookie': 'f=n; id58=c5/ns1i0+xkDn0dWA3XcAg==; commonTopbar_myfeet_tooltip=end; als=0; bj=2017230122113; bj58_id58s="dj03OFMrK09OdDJqOTQ0Mg=="; 58home=wh; __utma=253535702.1303251143.1488264259.1488264259.1488264259.1; __utmz=253535702.1488264259.1.1.utmcsr=bj.58.com|utmccn=(referral)|utmcmd=referral|utmcct=/zhaozu/; city=bj; showerweima=1; bj58_new_uv=1; bdshare_firstime=1488264398747; final_history=29215979853623; 58tj_uuid=688774c2-e614-4a76-bded-a0f22a70051e; new_session=0; new_uv=3; utm_source=; spm=; init_refer=; Hm_lvt_dcee4f66df28844222ef0479976aabf1=1488609980; Hm_lpvt_dcee4f66df28844222ef0479976aabf1=1488613559',
    'DNT': '1',
    'Host': 'bj.58.com',
    'Referer': 'http://bj.58.com/pinpaigongyu/?PGTID=0d3111f6-0000-1b14-1cd1-d5a425209107&ClickID=1',
    'Upgrade-Insecure-Requests': '1',
    'User-Agent': 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36'
}

agent = Mechanize.new
agent.request_headers = headers
listArray = Array.new

forumPage = agent.get('http://bj.58.com/pinpaigongyu/?minprice=600_1000')
nextPageLink = forumPage.parser.css("a.next")[0]
while (nextPageLink)
    # puts nextPageLink["href"]
    forumPage.parser.css("li[logr] a").each { |itemLink|
    itemPage = agent.get(itemLink["href"])
    desc = Hash.new

    textScript = itemPage.parser.css("script")[0].text

    desc["title"] = itemPage.parser.css("h2").text
    desc['price'] = "#{itemPage.parser.css("span.price").text} RMB/Mouth"
    desc['lon'] = textScript.match(/^\s*____json4fe.lon\s+=\s+\'\d+.\d+\'/)[0].slice(/\d+\.\d+/).to_f
    desc['lat'] = textScript.match(/^\s*____json4fe.lat\s+=\s+\'\d+.\d+\'/)[0].slice(/\d+\.\d+/).to_f
    desc['link'] = "http://bj.58.com"+itemLink['href']

    listArray << desc

    # p "============"
    # puts desc['title']
    # puts desc['price']
    # puts "lon = #{desc["lon"]}"
    # puts "lat = #{desc['lat']}"
    # puts "link = #{desc['link']}"
    # puts listArray
    # p "============"
    
    }
    forumPage = agent.get(nextPageLink["href"])
    nextPageLink = forumPage.parser.css("a.next")[0]
end

File.open("58-600-1000.json", 'w') { |f|
    f.puts listArray.to_json
}
