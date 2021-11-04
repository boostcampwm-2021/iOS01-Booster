import Foundation

struct UserInfo {
    let age: Int
    let nickname: String
    let gender: String
    let height: Int
    let weight: Int

    init(age: Int = 0, nickname: String = "", gender: String = "", height: Int = 0, weight: Int = 0) {
        self.age = age
        self.nickname = nickname
        self.gender = gender
        self.height = height
        self.weight = weight
    }
}
