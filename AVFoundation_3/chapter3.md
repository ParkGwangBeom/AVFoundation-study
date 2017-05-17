# Working with Assets and Metadata

## Understanding Assets
- AVAsset은 제목, 기간 및 메타 데이터와 같이 미디어의 정적 속성을 전체적으로 모델링하여 미디어의 복합 표현을 제공하는 추상 클래스이다.
- AVAsset이 추상화하는 두가지 측면
- 기본 미디어 형식에 대한 추상화 계층을 제공
- 리소스의 위치를 숨긴다.
- AVAsset은 미디어가 아니며 지정된 미디어의 컨테이너 역할을 한다. 

## Creating an Asset
- AVAsset은 추상클래스이므로 직접 인스턴스화 할수 없다.
- AVURLAsset 클래스를 사용하면 사전에 옵션을 전달하여 미세한 조정이 가능하다.
- ios assets, iPod, mac iTunes 등에서 해당 프레임워크들에서 원하는 항목을 찾아와 url을 가져와서 asset을 생성한다.

## iOS Assets Library
- ios는 사진 라이브러리에서 읽고 쓸 수 있는 AssetsLibrary를 제공한다.
- ALAssetsLibrary는 9.0에서 duplicated됨. PHPhotoLibrary를 사용해야 함.

## iOS iPod Library
- MediaPlayer 프레임워크는 iPod라이브러리에서 항목을 쿼리하고 검색할 api를 제공한다.
- MPMediaPropertyPredicate라는 클랙스는 iPod 라이브러리 내의 모든 항목을 찾을 수 있다.

## Mac iTunes Library
- iTunesLibrary 프레임워크를 통해서 라이브러리에 접근이 가능하다.
- MediaPlayer 프레임워크와 다르게 표쥰 NSPredicate를 이용해 쿼리를 구성하여 항목을 찾는 것이 가능하다.

## Asynchronous Loading
- AVAsset에는 메타데이터와 같은 Asset에 대한 정보를 제공하는 다양한 메소드와 속성이 존재 한다.
- AVAsset은 생성될 때 속성에 관한 접근은 항상 동기적으로 연결된다.
- 메인스레드에서 AVAsset 속성에 대한 접근을 하고자 할때에는 어플리케이션이 프리징 되므로 비동기적으로 해결해야 한다.
- AVAsset과 AVAssetTrack은 AVAsynchronousKeyValueLoading 프로토콜을 따른다.

## Media Metadata
- AVFoundation은 내용을 설명하는 메타 데이터를 임베드 할 수 있는 기능을 제공한다.
- AVFoundation은 대부분의 형식별 세부 정보를 추상화하여 쉽게 만들며 미디어 메타데이터로 작업하는 균일한 방법을 제공한다.

### Metadata Formats
- mov, mp4, m4v, m4a, mp3 다양한 미디어 포맷에 대해 AVFoundation은 이러한 파일에 포함 된 메타 데이터 작업을 위한 단일 인터페이스를 제공한다.

### QuickTime
### MPEG–4 Audio and Video
### MP3

## Working with Metadata
- AVAsset, AVAssetTrack은 관련 메타데이터에 대해 쿼리 할 수 있는 기능을 제공한다.
- 공통 키 공간 : 모든 미디어 유형에 공통저인 키를 정의. 제목, 아티스트 및 아트워크 정보 등이 들어감. 공통키 메타 데이터를 검색하려면 commonMetadata 속성을 요청.
- 형식별 키공간 : availableMetadataFormats를 활용하여 메타 데이터 형식을 정의하는 문자열을 반환 받을 수 있음.

## Finding Metadata
- 특정 메타 데이터 값을 찾고자 할때 AVMetadataItem에서 제공하는 api를 활용하여 필터링 할 수 있다.
- metadataItemsFromArray:withKey:keySpace :

## Using AVMetadataItem
- AVMetadataItem은 key value 래퍼이다.


