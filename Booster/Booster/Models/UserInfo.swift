import Foundation

struct UserInfo {
    var age: Int
    var nickname: String
    var gender: String
    var height: Int
    var weight: Int
    var goal: Int

    init(age: Int = 24,
         nickname: String = "",
         gender: String = "여",
         height: Int = 149,
         weight: Int = 59,
         goal: Int = 10000) {
        self.age = age
        self.nickname = nickname
        self.gender = gender
        self.height = height
        self.weight = weight
        self.goal = goal
    }
}
