import SwiftUI

// AI影评人枚举
enum AIReviewer: String, CaseIterable, Identifiable {
    case shenZhiYuan = "沈知远"
    case taoQiQi = "桃柒柒"
    case zhangDaiFu = "张戴夫"
    
    var id: String { self.rawValue }
    
    var description: String {
        switch self {
        case .shenZhiYuan: return "专业学术派，擅长剖析叙事结构与文化背景，评论深入理性"
        case .taoQiQi: return "感性大众派，评论直白易懂，常带迷妹视角与情绪化表达"
        case .zhangDaiFu: return "毒舌犀利派，善抓槽点，评论风格尖锐，常带批判性"
        }
    }
    
    var iconName: String {
        switch self {
        case .shenZhiYuan: return "ai_shenzy" // 需要提供图片资源
        case .taoQiQi: return "ai_taoqq" // 需要提供图片资源
        case .zhangDaiFu: return "ai_zhangdf" // 需要提供图片资源
        }
    }
    
    var placeholderIcon: String {
        switch self {
        case .shenZhiYuan: return "book.fill"
        case .taoQiQi: return "heart.fill"
        case .zhangDaiFu: return "flame.fill"
        }
    }
    
    var gradientColors: [Color] {
        switch self {
        case .shenZhiYuan: return [Color.blue, Color.purple]
        case .taoQiQi: return [Color.pink, Color.purple]
        case .zhangDaiFu: return [Color.red, Color.orange]
        }
    }
    
    func generateReview(for movieName: String) -> String {
        switch self {
        case .shenZhiYuan:
            return "《\(movieName)》在叙事结构上采用了经典的三幕式，但在第二幕的情节转折处融入了东方美学的留白概念，使剧情走向呈现出一种独特的节奏感。其中对时代背景的刻画尤为精准，不仅还原了特定历史时期的社会生态，更通过主角的情感发展映照了当代人对爱与责任的思考。从符号学的角度，影片中反复出现的意象既是对主题的隐喻，也是对角色内心世界的外化表达。作品在后现代语境下重新审视了战争与和平的永恒命题，其艺术价值和学术意义不言而喻。"
        case .taoQiQi:
            return "啊啊啊！《\(movieName)》真的是神剧本神演员！那场雨中表白的戏我反复看了好多遍，宋仲基的眼神也太会了吧！每次他看宋慧乔的时候，我整个人都酥了~剧中那些军装造型简直帅炸天，而且OST也超级上头，我已经单曲循环《Always》一个星期了。虽然结局有点虐但也很圆满啦，这种甜中带虐的感觉真的很上头！总之这是一部不管看多少遍都不会腻的剧，五星推荐给所有人！爱情加军事题材的完美结合，谁能不爱呢？❤️"
        case .zhangDaiFu:
            return "《\(movieName)》，又一部披着现实主义外衣的偶像剧。军人形象？可笑。现实中的军人哪有时间天天谈情说爱。女主角设定更是满满的玛丽苏，一个医生有必要每集都完美妆容吗？战区环境如此恶劣，女主光洁脸蛋上的粉底是擦不掉的吗？剧情处处是硬伤，逻辑漏洞比筛子还多，编剧是小学毕业吗？还有那个莫名其妙的反派，演技浮夸到尴尬。评分这么高只能说明粉丝控评成功。这种为了博取流量而不顾常识的剧，也就骗骗颜值脑残粉了。"
        }
    }
} 