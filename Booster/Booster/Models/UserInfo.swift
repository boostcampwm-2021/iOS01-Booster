import Foundation

struct UserInfo {
    let age: Int
    let nickname: String
    let gender: String
    let height: Int
    let weight: Int

    init(age: Int = 25, nickname: String = "", gender: String = "M", height: Int = 170, weight: Int = 60) {
        self.age = age
        self.nickname = nickname
        self.gender = gender
        self.height = height
        self.weight = weight
    }
}
