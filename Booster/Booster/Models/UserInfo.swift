import Foundation

struct UserInfo {
    var age: Int
    var nickName: String
    var gender: String
    var height: Int
    var weight: Int

    init(age: Int = 24, nickName: String = "", gender: String = "여", height: Int = 149, weight: Int = 59) {
        self.age = age
        self.nickName = nickName
        self.gender = gender
        self.height = height
        self.weight = weight
    }
}
