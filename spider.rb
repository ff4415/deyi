
require 'mechanize'
require 'mail'

def mailToQQ(qqSubject, qqBody)
    Mail.defaults do
        delivery_method :smtp,    :address    => "smtp.qq.com",
        :port       => 587,
        :user_name  => 'ff4415@qq.com',
        :password   => 'akuiesppmjqobhdf',
        :enable_ssl => true

    end

    Mail.deliver do
        from    'ff4415@qq.com'
        to      'ff4415@qq.com'
        subject qqSubject
        body    qqBody
    end
end
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
totalPageNumber = 0


while (forumPageLink = forumPage_links.shift)
    forumPage = forumPageLink.click
    nextforumPageLink = forumPage.parser.css("a.nxt")[0]
    fileName = forumPageLink.href.sub(/http:\/\/www.deyi.com\//, '').chomp(".html")
    File.open("#{fileName}",'w') { |f|
        while true
            # puts "forumPage = #{forumPage.class}"
            # puts "nextforumPageLink = #{nextforumPageLink}"
            forumPage.parser.css("a.xst").each {|forumItemLink|
                # puts "forumItemLink = #{forumItemLink}"
                pageItem = agent.get(forumItemLink['href'])
                nextPageLink = pageItem.parser.css("a.nxt")[0]
                while true
                    # p "pageItem = #{pageItem.class}"
                    # puts "nextPageLink = #{nextPageLink}"
                    begin
                    pageItem.parser.css("td.t_f").text.split("\n").each { |message|
                        f.puts message.strip
                    }
                    nextPageLink ? pageItem = agent.get(nextPageLink['href']) : break
                    nextPageLink = pageItem.parser.css("a.nxt")[0]
                    
                    rescue Mechanize::ResponseCodeError
                        mailToQQ "#{$!.class}", "code = #{$!.response_code}, current_page= #{agent.page}"
                    rescue Mechanize::ResponseReadError
                        mailToQQ "#{$!.class}", "code = #{$!.response_code} error = #{$!.error} uri = #{$!.uri}"
                    rescue
                        mailToQQ "#{$!.class}", "message = #{$!.message}, current_page = #{agent.page}"
                    end
                end #end while
                sleep rand * 10
                totalPageNumber += 1
            } #end_forumItemLink.each
            nextforumPageLink ? forumpage = agent.get(nextforumPageLink['href']) : break
            nextforumPageLink = forumpage.parser.css("a.nxt")[0]
            f.puts "totalPageNumber = #{totalPageNumber}"
        end #end_while
    } #end file#open
    Thread.new {
        mailToQQ "#{fileName}", File.read(fileName)
    }
end #end while forumPageLink
