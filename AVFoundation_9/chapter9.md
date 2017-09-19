# Composing and Editing Media

- 편집은 중요함. AVFoundation은 비선형, 비파괴 편집 도구 및 응용프로그램을 작성하기 위한 API를 제공함. (비선형: 순서대로 미디어 클립을 결합, 분할, 자르기, 겹치기 및 재정렬 할 수 있음)

## Composing Media
- 여러 영상을 하나의 영상으로 결합 하려면 원본 미디어에서 관련 세그먼트를 추출하여 임시 배열로 구성해야 함.
이미지

- AVFoundation의 구성 기능은 AVComposition이라는 AVAsset의 하위 클래스를 중심으로 구성된다.
- 컴포지션은 다른 미디어 자산을 맞춤 시간 배열로 결합하여 단일 미디어 항목으로 제시하거나 처리할 수 있도록 함.

이미지
- AVComposition은 AVAsset을 확장하므로 재생, 이미지 추출 또는 내보내기와 같은 일반 자산을 사용하는 모든 시나리오에서 사용할 수 있음.
- AVAsset이 특정 미디어 파일에 직접 일대일 매핑을 하는 반면 컴포지션은 미디어의 여러 소스를 일괄적으로 제시하거나 처리하는 방법과 비슷함.

## Working with Time
### CMTime
- 미디어 작업의 고급 요구 사항을 충적시키기 위해 Core Media 프레임워크의 CMTime 데이터 유형에 의해 정의된 숫자로 나타냄.

### CMTimeRange
- CMTimeRange를 만드는 방법은 몇가지가 존재함
1. CMTimeRangeMake(start, duration)
2. CMTimeRangeFromTimeToTime(start, end)

## Basic Recipe
- 컴포지션을 만들기 위해서는 하나 이상의 AVAsset이 필요함.

**뒤에는 다 예제관련… 특별히 정리할것이 없음…**
## Introducing 15 Seconds
## View Controller Composition
## Building a Composition
## Building the Composition Builder
## Exporting the Composition
