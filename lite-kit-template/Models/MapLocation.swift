import Foundation

struct MapLocation: Equatable {
    let name: String
    let latitude: Double
    let longitude: Double
    let description: String
    
    static let beijing = MapLocation(
        name: "北京",
        latitude: 39.9042,
        longitude: 116.4074,
        description: "中国首都"
    )
    
    static let shanghai = MapLocation(
        name: "上海",
        latitude: 31.2304,
        longitude: 121.4737,
        description: "魔都"
    )
    
    static let guangzhou = MapLocation(
        name: "广州",
        latitude: 23.1291,
        longitude: 113.2644,
        description: "花城"
    )
    
    static let shenzhen = MapLocation(
        name: "深圳",
        latitude: 22.5431,
        longitude: 114.0579,
        description: "经济特区"
    )
}