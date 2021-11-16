import Foundation

struct UserInfo {
    var age: Int
    var nickname: String
    var gender: String
    var height: Int
    var weight: Int

    init(age: Int = 25, nickname: String = "", gender: String = "M", height: Int = 170, weight: Int = 60) {
        self.age = age
        self.nickname = nickname
        self.gender = gender
        self.height = height
        self.weight = weight
    }
}
