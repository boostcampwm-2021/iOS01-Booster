# Booster🚀🔥
![간판](https://user-images.githubusercontent.com/48645631/139188593-436c66bd-eaa6-4275-88f3-fd425dbc9053.png)

<div align="center">
    
## 멤버
<div align="center">
<center>

|<img src="https://i.imgur.com/wIXr1QY.png" width=18px> <b style="color:#FF5C00">S014_김태훈</b> | <img src="https://i.imgur.com/wIXr1QY.png" width=18px> <b style="color:#FF5C00">S025_신명섭</b> | <img src="https://i.imgur.com/wIXr1QY.png" width=18px> <b style="color:#FF5C00">S050_이하원</b>  | <img src="https://i.imgur.com/wIXr1QY.png" width=18px> <b style="color:#FF5C00">S060_최희주</b> |
|:-:|:-:|:-:|:-:|
|<img src="https://i.imgur.com/I3g5HkU.png" width="150">|<img src="https://i.imgur.com/GNC10jI.png" width="150">|<img src="https://i.imgur.com/jFNY6Sy.png" width="150">|<img src="https://i.imgur.com/cdOsNrV.png" width="150">
| [@KTH-INHA-16](https://github.com/KTH-INHA-16) | [@s1gnature](https://github.com/s1gnature)   | [@Hani-Levenshtein](https://github.com/Hani-Levenshtein)       | [@rose6649](https://github.com/rose6649)   |
    
</center>
</div>
<center>
<h2></h2>
<h2><a href="https://drive.google.com/file/d/1CNYS-sfW_2_-8XrEFUkVxtWWV8voyOw8/view?usp=sharing">🌈 기획서</a>
<br>
<br>
<a href="https://github.com/boostcampwm-2021/iOS01-Booster/wiki">📁 위키</a><br>
<br>
</h2>
<br>

[![Hits](https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2Fboostcampwm-2021%2FiOS01-Booster&count_bg=%23FF5C00&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=Booster%F0%9F%9A%80%F0%9F%94%A5&edge_flat=false)](https://hits.seeyoufarm.com)<br>
[![Swift](https://img.shields.io/badge/swift-v5.5-orange?logo=swift)](https://developer.apple.com/kr/swift/) [![Xcode](https://img.shields.io/badge/xcode-v13.0-blue?logo=xcode)](https://developer.apple.com/kr/xcode/) [![Figma](https://img.shields.io/badge/Figma-0C0C0C?logo=figma)](https://www.figma.com/) 
[![Cocoapods](https://img.shields.io/badge/Cocoapods-6933FF?logo=cocoapods)](https://cocoapods.org/) [![RxSwift](https://img.shields.io/badge/RxSwift-B7178C?logo=reactiveX)](https://github.com/ReactiveX/RxSwift/)
</center>
</div>
<br>    
<H1>
</H1>
<br>
<div>
<center> 
    <img src="https://i.imgur.com/6BZsKkQ.png" width=120px><br><br>
    <H3>부스터는 <b style="color:#ff5c00">오늘의 걸음 수</b>를 보여주고<br><br>
        걸음을 <b style="color:#ff5c00">트래킹</b>하면서<br><br>
        <b style="color:#ff5c00">산책 기록을 모아</b> 추억을 쌓는 🍎 iOS 앱입니다
    </H3>


##### 산책으로 오늘 하루도 힐링해보시는 건 어떠세요? 🚶🚶🏼🚶🏼
</div>
</center>
    
<br>
<br>
    
## 설치 방법
   **Booster를 직접 사용해 보아요 🚀🔥**
1. Xcode 13(권장) 이상과 Cocoapods이 설치되어있어야 합니다.
    > `brew install cocoapods` - Cocoapods 설치
2. 프로젝트를 로컬에 클론 하게 되면 프로젝트 디렉토리에서 
    `pod install`을 실행 시켜 주세요.
3. 이후 Booster.xcworkspace를 실행 한 이후 `command + R`을 통해 체험 가능합니다.
<br>
<br>
    
## 기능 소개

| 오늘의 걸음 수 ✨ | 걸음 수 통계 ✨ | 산책 트래킹 ✨ |
| -------- | -------- | -------- |
|  <img src="https://i.imgur.com/n0ZJPhL.jpg" width=200px> | <img src="https://i.imgur.com/NfQ9oz1.jpg" width=200px> | <img src="https://i.imgur.com/A1li5NA.png" width=200px> |

| 산책 기록들 ✨ | 하나의 기록도 소중히 ✨ | 마이페이지 ✨ |
| -------- | -------- | -------- |
|  <img src="https://i.imgur.com/pPI6gVY.png" width=200px> | <img src="https://i.imgur.com/7OTm0N8.png" width=200px> | <img src="https://i.imgur.com/XHpNEXG.png" width=200px> |    


    
<br><br>
## 아키텍쳐
> Booster에서 사용한 아키텍쳐를 도식화한 이미지입니다.
> MVVM을 기본으로 하는 아키텍쳐 입니다.

![](https://i.imgur.com/UVbUI22.png)

ViewModel이 각 Manager들에 접근할 존재는 필요했고, 해당 로직을 ViewModel에서 모두 처리하기에는 ViewModel의 크기가 커지기에 UseCase를 남겨두고 해당 비지니스 로직을 UseCase에서 처리했습니다.
> [🍌참고](https://github.com/boostcampwm-2021/iOS01-Booster/wiki/MVVM%3F-or-Clean-Architecture-%EA%B3%A0%EC%B0%B0%EC%97%90-%EB%8C%80%ED%95%9C-%EA%B2%B0%EA%B3%BC)

<br><br>
    
## 프레임워크
> Booster에서 사용한 프레임워크 입니다.
    
![](https://i.imgur.com/wn03W7p.png)

#### HealthKit
- 같은 애플 계정을 공유하는 기기간 연동된 건강 데이터를 활용하기 위해 선택하였습니다
- 앱을 다운로드 받기 전과 트래킹하지 않았을 때의 걸음 수까지 보여주기 위해 사용하였습니다
- 트래킹 정보를 저장한 뒤, 건강 앱에도 기록되어 이 정보를 앱에 함께 불러올 수 있었습니다

#### CoreData
- 네트워크 상황에 관계 없이 기록을 저장하고 보여주기 위하여 사용하였습니다
- NSPredicate 사용해 CRUD를 구현하여 CoreData에 접근을 용이하게 하도록 구현하였습니다
- 동시성을 위해 main loop가 아닌 private context(child context)를 활용하였습니다

#### MapKit
- 다른 라이브러리를 이용하지 않고, 애플 지도를 이용하여 사용자의 트래킹 정보를 표현하기 위해 사용하였습니다
- 트래킹한 사용자의 위치 정보를 지도상에 나타내기 위해 MKPolyLine을 이용하였습니다
- 사용자의 현 위치에 마일스톤 기록을 남기기 위하여 MKAnnotationView를 커스텀 하여 표현하였습니다

#### RxSwift
> 계기
- escaping closure와 같은 비동기 처리가 많아졌고, 이를 처리하는 방식이 매개변수와 같이 있어 다른 방법으로 표현할 수 없을까 고민하였습니다 
- 데이터 바인딩, UI 이벤트 처리에 대한 코드가 나눠져서 불편함이 생겨 코드를 보았을 때 이해하기 쉽도록 하고 싶었습니다

> 도입 결과
- IBAction/UIGesture와 Target method를 통합하여 하나의 스트림으로 표현할 수 있었습니다
- escaping closure에서 벗어나 리턴값으로 Observable을 사용하게 되면서 간결한 코드로 나타낼 수 있었습니다
- 기존에 직접 만든 Observable 클래스 만으로는 할 수 없었던 NSObject에서도 Rx에 관한 작업들을 할 수 있었습니다

#### CoreLocation
- 디바이스의 위치 정보를 추적하여 사용자의 위치를 실시간으로 추적하고자 사용하였습니다
- 사용자의 위치에 대한 위도/경도 정보를 통해 지역명으로 받아오고자 CLGeocoder를 이용했습니다
