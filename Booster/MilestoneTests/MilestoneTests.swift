//
//  MilestoneTests.swift
//  MilestoneTests
//
//  Created by mong on 2021/11/29.
//

import XCTest
@testable import Booster

class MilestoneTests: XCTestCase {
    var milestones: Milestones!
    
    override func setUpWithError() throws {
        milestones = Milestones()
    }

    override func tearDownWithError() throws {
        milestones = nil
    }

    func test_초기화_기본_성공() throws {
        // given
        let newMilestones: Milestones!
        let milestonesList: [Milestone] = []

        // when
        newMilestones = Milestones()

        // then
        XCTAssertEqual(newMilestones.all, milestonesList, "배열이 정상적으로 초기화 되지 않았습니다.")
    }

    func test_초기화_배열_성공() throws {
        // given
        let newMilestones: Milestones!
        let milestonesList = [
            Milestone(latitude: 1, longitude: 1, imageData: Data()),
            Milestone(latitude: 2, longitude: 2, imageData: Data()),
            Milestone(latitude: 3, longitude: 3, imageData: Data())
        ]

        // when
        newMilestones = Milestones(milestones: milestonesList)

        // then
        XCTAssertEqual(newMilestones.all, milestonesList, "배열이 정상적으로 초기화 되지 않았습니다.")
    }

    func test_마일스톤추가_성공() throws {
        // given
        let newMilestone = Milestone(latitude: 1, longitude: 1, imageData: Data())
        
        // when
        milestones.append(newMilestone)
        
        // then
        XCTAssertEqual(milestones.all, [newMilestone], "마일스톤 추가에 실패하였습니다.")
    }

    func test_마일스톤추가_배열_성공() throws {
        // given
        let milestonesList = [
            Milestone(latitude: 1, longitude: 1, imageData: Data()),
            Milestone(latitude: 2, longitude: 2, imageData: Data()),
            Milestone(latitude: 3, longitude: 3, imageData: Data())
        ]
        
        // when
        milestones.appends(milestonesList)
        
        // then
        XCTAssertEqual(milestones.all, milestonesList, "마일스톤배열 추가에 실패하였습니다.")
    }

    func test_첫번째_마일스톤() throws {
        // given
        let first = Milestone(latitude: 1, longitude: 1, imageData: Data())
        let milestonesList = [
            first,
            Milestone(latitude: 2, longitude: 2, imageData: Data()),
            Milestone(latitude: 3, longitude: 3, imageData: Data())
        ]
        
        // when
        milestones.appends(milestonesList)
        
        // then
        XCTAssertEqual(milestones.first, first, "첫번째 마일스톤이 일치하지 않습니다.")
    }

    func test_마지막_마일스톤() throws {
        // given
        let last = Milestone(latitude: 1, longitude: 1)
        let milestonesList = [
            Milestone(latitude: 2, longitude: 2, imageData: Data()),
            Milestone(latitude: 3, longitude: 3, imageData: Data()),
            last
        ]
        
        // when
        milestones.appends(milestonesList)
        
        // then
        XCTAssertEqual(milestones.last, last, "마지막 마일스톤이 일치하지 않습니다.")
    }
    
    func test_마일스톤_갯수() throws {
        // given
        let count = 3
        let milestonesList = [
            Milestone(latitude: 1, longitude: 1, imageData: Data()),
            Milestone(latitude: 2, longitude: 2, imageData: Data()),
            Milestone(latitude: 3, longitude: 3, imageData: Data())
        ]
        
        // when
        milestones.appends(milestonesList)
        
        // then
        XCTAssertEqual(milestones.count, count, "마일스톤의 갯수가 일치하지 않습니다.")
    }

    func test_전체_마일스톤() throws {
        // given
        let milestonesList = [
            Milestone(latitude: 1, longitude: 1, imageData: Data()),
            Milestone(latitude: 2, longitude: 2, imageData: Data()),
            Milestone(latitude: 3, longitude: 3, imageData: Data())
        ]
        
        // when
        milestones.appends(milestonesList)
        
        // then
        XCTAssertEqual(milestones.all, milestonesList, "마일스톤 전체가 일치하지 않습니다.")
    }

    func test_마일스톤_인덱스_찾기_성공() throws {
        // given
        let milestonesList = [
            Milestone(latitude: 30, longitude: 40, imageData: Data()),
            Milestone(latitude: 20, longitude: 60, imageData: Data()),
            Milestone(latitude: 10, longitude: 80, imageData: Data())
        ]
        let targetmilestone = Milestone(latitude: 20, longitude: 60, imageData: Data())
        
        // when
        milestones.appends(milestonesList)
        
        // then
        XCTAssertEqual(milestones.firstIndex(of: targetmilestone), 3, "해당 마일스톤이 존재하지 않습니다.")
    }

    func test_마일스톤_인덱스_찾기_실패() throws {
        // given
        let milestonesList = [
            Milestone(latitude: 30, longitude: 40, imageData: Data()),
            Milestone(latitude: 20, longitude: 60, imageData: Data()),
            Milestone(latitude: 10, longitude: 80, imageData: Data())
        ]
        let targetmilestones = Milestone(latitude: 10, longitude: 10, imageData: Data())
        
        // when
        milestones.appends(milestonesList)
        
        // then
        XCTAssertNil(milestones.firstIndex(of: targetmilestones), "해당 마일스톤이 존재합니다.")
    }

    func test_마일스톤_삭제_성공() throws {
        // given
        let milestonesList = [
            Milestone(latitude: 30, longitude: 40, imageData: Data()),
            Milestone(latitude: 20, longitude: 60, imageData: Data()),
            Milestone(latitude: 10, longitude: 80, imageData: Data())
        ]
        let targetmilestones = Milestone(latitude: 10, longitude: 80, imageData: Data())
        
        // when
        milestones.appends(milestonesList)
        let removedMilestone = milestones.remove(of: targetmilestones)
        
        // then
        XCTAssertEqual(removedMilestone, targetmilestones, "해당 마일스톤이 존재하지 않습니다.")
    }
    
    func test_마일스톤_삭제_실패() throws {
        // given
        let milestonesList = [
            Milestone(latitude: 30, longitude: 40, imageData: Data()),
            Milestone(latitude: 20, longitude: 60, imageData: Data()),
            Milestone(latitude: 10, longitude: 80, imageData: Data())
        ]
        let targetmilestones = Milestone(latitude: 10, longitude: 80, imageData: Data())
        
        // when
        milestones.appends(milestonesList)
        let removedMilestone = milestones.remove(of: targetmilestones)
        
        // then
        XCTAssertNil(removedMilestone, "해당 마일스톤이 존재합니다.")
    }
    
    func test_좌표에_해당하는_마일스톤_찾기_성공() throws {
        // given
        let milestonesList = [
            Milestone(latitude: 30, longitude: 40, imageData: Data()),
            Milestone(latitude: 20, longitude: 60, imageData: Data()),
            Milestone(latitude: 10, longitude: 80, imageData: Data())
        ]
        let targetCoordinate = Coordinate(latitude: 10, longitude: 80)
        
        // when
        milestones.appends(milestonesList)
        guard let resultMilestone = milestones.milestone(at: targetCoordinate)
        else {
            XCTFail("해당 마일스톤이 존재하지 않습니다(Nil)")
            return
        }
        
        // then
        XCTAssertEqual(resultMilestone.coordinate, targetCoordinate, "해당 마일스톤이 존재하지 않습니다(Coordinate).")
    }
    
    func test_좌표에_해당하는_마일스톤_찾기_실패() throws {
        // given
        let milestonesList = [
            Milestone(latitude: 30, longitude: 40, imageData: Data()),
            Milestone(latitude: 20, longitude: 60, imageData: Data()),
            Milestone(latitude: 10, longitude: 80, imageData: Data())
        ]
        let targetCoordinate = Coordinate(latitude: 10, longitude: 80)
        
        // when
        milestones.appends(milestonesList)
        let resultMilestone = milestones.milestone(at: targetCoordinate)
        
        // then
        XCTAssertNil(resultMilestone, "해당 마일스톤이 존재합니다.")
    }
}
