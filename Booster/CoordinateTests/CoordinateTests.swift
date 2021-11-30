//
//  CoordinateTests.swift
//  CoordinateTests
//
//  Created by mong on 2021/11/28.
//

import XCTest

class CoordinateTests: XCTestCase {
    var coordinates: Coordinates!

    override func setUpWithError() throws {
        coordinates = Coordinates()
    }

    override func tearDownWithError() throws {
        coordinates = nil
    }

    func test_초기화_기본_성공() throws {
        // given
        let newCoordinates: Coordinates!
        let coordinateList: [Coordinate] = []

        // when
        newCoordinates = Coordinates()

        // then
        XCTAssertEqual(newCoordinates.all, coordinateList, "배열이 정상적으로 초기화 되지 않았습니다.")
    }
    
    func test_초기화_기본값_성공() throws {
        // given
        let newCoordinate = Coordinate(latitude: 1, longitude: 1)

        // when
        coordinates = Coordinates(coordinate: newCoordinate)

        // then
        XCTAssertEqual(coordinates.all, [newCoordinate], "배열이 정상적으로 초기화 되지 않았습니다.")
    }
    
    func test_초기화_배열_성공() throws {
        // given
        let newCoordinates: Coordinates!
        let coordinateList = [
            Coordinate(latitude: 1, longitude: 1),
            Coordinate(latitude: 2, longitude: 2),
            Coordinate(latitude: 3, longitude: 3)
        ]

        // when
        newCoordinates = Coordinates(coordinates: coordinateList)

        // then
        XCTAssertEqual(newCoordinates.all, coordinateList, "배열이 정상적으로 초기화 되지 않았습니다.")
    }

    func test_좌표추가_성공() throws {
        // given
        let coordinate = Coordinate(latitude: 1, longitude: 1)

        // when
        coordinates.append(coordinate)

        // then
        XCTAssertEqual(coordinates.all, [coordinate], "좌표 추가에 실패하였습니다.")
    }

    func test_좌표추가_배열_성공() throws {
        // given
        let coordinateList = [
            Coordinate(latitude: 1, longitude: 1),
            Coordinate(latitude: 2, longitude: 2),
            Coordinate(latitude: 3, longitude: 3)
        ]

        // when
        coordinates.appends(coordinateList)

        // then
        XCTAssertEqual(coordinates.all, coordinateList, "좌표배열 추가에 실패하였습니다.")
    }

    func test_첫번째_좌표() throws {
        // given
        let first = Coordinate(latitude: 1, longitude: 1)
        let coordinateList = [
            first,
            Coordinate(latitude: 2, longitude: 2),
            Coordinate(latitude: 3, longitude: 3)
        ]

        // when
        coordinates.appends(coordinateList)

        // then
        XCTAssertEqual(coordinates.first, first, "첫번째 좌표가 일치하지 않습니다.")
    }

    func test_마지막_좌표() throws {
        // given
        let last = Coordinate(latitude: 1, longitude: 1)
        let coordinateList = [
            Coordinate(latitude: 2, longitude: 2),
            Coordinate(latitude: 3, longitude: 3),
            last
        ]

        // when
        coordinates.appends(coordinateList)

        // then
        XCTAssertEqual(coordinates.last, last, "마지막 좌표가 일치하지 않습니다.")
    }

    func test_좌표_갯수() throws {
        // given
        let count = 3
        let coordinateList = [
            Coordinate(latitude: 1, longitude: 1),
            Coordinate(latitude: 2, longitude: 2),
            Coordinate(latitude: 3, longitude: 3)
        ]

        // when
        coordinates.appends(coordinateList)

        // then
        XCTAssertEqual(coordinates.count, count, "좌표의 갯수가 일치하지 않습니다.")
    }

    func test_전체_좌표() throws {
        // given
        let coordinateList = [
            Coordinate(latitude: 1, longitude: 1),
            Coordinate(latitude: 2, longitude: 2),
            Coordinate(latitude: 3, longitude: 3)
        ]

        // when
        coordinates.appends(coordinateList)

        // then
        XCTAssertEqual(coordinates.all, coordinateList, "좌표 전체가 일치하지 않습니다.")
    }

    func test_중앙좌표_일치() throws {
        // given
        let center = Coordinate(latitude: 15, longitude: 40)
        let coordinateList = [
            Coordinate(latitude: 30, longitude: 40),
            Coordinate(latitude: 20, longitude: 60),
            Coordinate(latitude: 10, longitude: 80)
        ]
        // when
        coordinates.appends(coordinateList)

        // then
        XCTAssertEqual(coordinates.center(), center, "좌표의 중앙이 일치하지 않습니다.")
    }

    func test_좌표_인덱스_찾기_성공() throws {
        // given
        let coordinateList = [
            Coordinate(latitude: 30, longitude: 40),
            Coordinate(latitude: 20, longitude: 60),
            Coordinate(latitude: 10, longitude: 80)
        ]
        let targetCoordinate = Coordinate(latitude: 20, longitude: 60)

        // when
        coordinates.appends(coordinateList)

        // then
        XCTAssertEqual(coordinates.firstIndex(of: targetCoordinate), 1, "해당 좌표가 존재하지 않습니다.")
    }

    func test_좌표_인덱스_찾기_실패() throws {
        // given
        let coordinateList = [
            Coordinate(latitude: 30, longitude: 40),
            Coordinate(latitude: 20, longitude: 60),
            Coordinate(latitude: 10, longitude: 80)
        ]
        let targetCoordinate = Coordinate(latitude: 10, longitude: 10)

        // when
        coordinates.appends(coordinateList)

        // then
        XCTAssertNil(coordinates.firstIndex(of: targetCoordinate), "해당 좌표가 존재합니다.")
    }
    
    func test_좌표_비율() throws {
        // given
        let targetCoordinate = Coordinate(latitude: 2, longitude: 2)
        let coordinateList = [
            Coordinate(latitude: 1, longitude: 1),
            targetCoordinate,
            Coordinate(latitude: 3, longitude: 3),
            Coordinate(latitude: 4, longitude: 4),
        ]
        coordinates.appends(coordinateList)

        // when
        let expectRatio: Double = 1 / Double(coordinateList.count)
        guard let resultRatio = coordinates.indexRatio(targetCoordinate)
        else {
            XCTFail("존재하지 않는 좌표입니다.")
            return
        }

        // then
        XCTAssertEqual(resultRatio, expectRatio, "좌표의 인덱스 비율이 일치하지 않습니다.")
    }
}
