
require 'mechanize'
require 'mail'

headers = {
    'Host': 'www.deyi.com',
    'Connection': 'keep-alive',
    'Cache-Control': 'max-age=0',
    'Upgrade-Insecure-Requests': '1',
    'User-Agent': 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.99 Safari/537.36a',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
    'DNT': '1',
    'Accept-Encoding': 'gzip, deflate, sdch',
    'Accept-Language': 'zh-CN,zh;q=0.8,en-US;q=0.6,en;q=0.4',
    'Cookie': 'oPgi_7ff9_saltkey=1734c3a998a3012a7864aa0978bc0c9d; oPgi_7ff9_lastvisit=1479391045; adv%5Fsy-zydl-1_4696=Y; oPgi_7ff9_lastact=1480680007%09forum.php%09viewthread; js-qrcode; Hm_lvt_b051b14789f4b43a39316713ae0ac54a=1480669866; Hm_lpvt_b051b14789f4b43a39316713ae0ac54a=1480680033'
}

agent = Mechanize.new
agent.request_headers = headers

forumPage = agent.get('http://www.deyi.com/forum.php')

forumPage_links = forumPage.links_with(:href => /www.deyi.com\/forum-\d+-\d+.html/).compact

# File.open('forum','w') { |f|
#     page_links.each { |link|
#         f.puts link.href
#     }
# }
# link = page_links[0]
# page_links.each { |link|
while (forumPageLink = forumPage_links.shift)
    forumPage = forumPageLink.click
    nextforumPageLink = forumPage.parser.css("a.nxt")[0]
    File.open("#{forumPageLink.href.sub(/http:\/\/www.deyi.com\//, '').chomp(".html")}",'w') { |f|
        while true
            puts "forumPage = #{forumPage.class}"
            puts "nextforumPageLink = #{nextforumPageLink}"
            forumPage.parser.css("a.xst").each {|forumItemLink|
                puts "forumItemLink = #{forumItemLink}"
                pageItem = agent.get(forumItemLink['href'])
                nextPageLink = pageItem.parser.css("a.nxt")[0]
                while true
                    p "pageItem = #{pageItem.class}"
                    puts "nextPageLink = #{nextPageLink}"

                    pageItem.parser.css("td.t_f").text.split("\n").each_with_index { |message, index|
                        f.puts  "#{index}" + message.strip
                    }

                    nextPageLink ? pageItem = agent.get(nextPageLink['href']) : break
                    nextPageLink = pageItem.parser.css("a.nxt")[0]
                    sleep rand * 10
                end #end while
            } #end_forumItemLink.each
            nextforumPageLink ? forumpage = agent.get(nextforumPageLink['href']) : break
            nextforumPageLink = forumpage.parser.css("a.nxt")[0]
        end #end_while
    } #end file#open
end #end while forumPageLink
# File.open('items','w') { |f|

        # page = agent.get('http://www.deyi.com/thread-10156881-1-1.html')
        # item = page.parser.css("a.nxt")[0]
        # until page == nil
        #         page.parser.css("td.t_f").text.split("\n").each_with_index { |message, index|
        #             f.puts  "#{index}" + message.strip
        #         }
        #         item ? page = agent.get(item['href']) : break
        #         item = page.parser.css("a.nxt")[0]
        # end
    # link.click.parser.css("a.xst").each {|item|
    #     until page == nil
    #     item ? page = agent.get(item['href']) : break
    #     item = page.parser.css("a.nxt")[0]
    #         page.parser.css("td.t_f").text.split("\n").each_with_index { |message, index|
    #         f.puts  "#{index}" + message.strip
    #     }
    #     end
        # sleep rand * 10
# } #end-link-loop
# } #end -file-items
# }

# pp agent.request_headers

# page = agent.page.parser.css("td.t_f").text.split("\n")
# p page.count
# page.each_with_index do |item,index|
# puts  "#{index}" + item
# end
# page.links.each do |link|
# puts link.text
# end

# page = agent.page.link_with(:text => '幼儿园五星级伙食品鉴会，甩我公司食堂100条街！').click until agent.page.parser.css("div.nxt").empty?
