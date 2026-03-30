# Run Run

Flutter와 iOS HealthKit을 연동한 러닝 앱입니다.

GPS 위치와 CMPedometer를 실시간으로 수집하고, 수집된 데이터를 HealthKit의 `HKWorkoutBuilder`를 통해 Apple Health에 저장합니다.

---

## 프로젝트 의도

Flutter에서 iOS 네이티브 기능(HealthKit, CMPedometer)을 MethodChannel / EventChannel로 연동하는 구조를 직접 설계하고 구현하는 것이 목표입니다.

단순한 패키지 사용에 그치지 않고, 아래 항목들을 직접 다루는 것에 집중했습니다.

- Flutter ↔ Swift 간 양방향 통신 구조 설계 (MethodChannel, EventChannel)
- Clean Architecture 기반의 레이어 분리
- 배치 기반 HealthKit 저장으로 성능 최적화
- DataSource를 주입 가능한 구조로 만들어 단위 테스트 작성

---

## 기술 스택

| 분류 | 기술                                 |
|---|------------------------------------|
| Framework | Flutter 3.x, Swift                 |
| 상태 관리 | flutter_bloc 9.x (BLoC 패턴)         |
| 지도 | Flutter Naver Map                  |
| GPS | geolocator                         |
| 걸음수 | CMPedometer (iOS - EventChannel)   |
| 건강 데이터 | HealthKit (HKWorkoutBuilder)       |
| 직렬화 | json_serializable, json_annotation |
| 환경변수 | flutter_dotenv                     |
| 테스트 | flutter_test, mocktail             |
| 코드 생성 | build_runner                       |

---

## 주요 기능

### 러닝 추적
- GPS 기반 실시간 위치 추적 및 경로 기록
- CMPedometer 기반 걸음수 / 케이던스 / 페이스 실시간 표시
- 지도에 실제 이동 경로를 시각화 (Naver Map)

### HealthKit 저장
- 러닝 세션을 `HKWorkoutBuilder`로 구성
- 위치 샘플(`CLLocation`), 거리 샘플(`HKQuantitySample`), 걸음수 샘플을 5초 단위로 배치 저장
- 세션 종료 시 `finishWorkout()`으로 Apple Health에 최종 저장

### 운동 기록 조회
- HealthKit에 저장된 러닝 기록 목록 / 상세 데이터 조회

### GPS 필터링
- 속도 기반 이상치 제거 (15 m/s 초과 좌표 제거)
- Kalman Filter를 이용한 GPS 좌표 스무딩

---

## 아키텍처

Clean Architecture를 기반으로 세 레이어로 분리했습니다.

```
lib/
├── presentation/        # UI (Page, BLoC, Widget)
├── domain/              # 비즈니스 로직 (UseCase, Repository 인터페이스, Entity)
└── data/                # 데이터 (Repository 구현, DataSource, DTO, 필터)
```

### 레이어 간 데이터 흐름

```
iOS Native (HealthKit / CMPedometer)
    ↕ MethodChannel / EventChannel
DataSource
    ↕ DTO
Repository
    ↕ Entity
UseCase
    ↕
BLoC → UI
```

### BLoC 구성

| BLoC | 역할 |
|---|---|
| WorkoutBloc | 러닝 세션 상태 (시작 / 일시정지 / 종료), 타이머, 5초 배치 저장 트리거 |
| LocationBloc | GPS 위치 수신, 누적 거리 / 페이스 계산 |
| PedometerBloc | 걸음수 / 케이던스 / 페이스 실시간 업데이트 |
| MapBloc | 지도 경로 좌표 관리 |

---

## iOS 네이티브 구조

```
ios/Runner/
├── AppDelegate.swift                  # MethodChannel / EventChannel 초기화
├── EventHandler/
│   ├── WorkoutHandler.swift          # HKWorkoutBuilder 제어 (start / pause / finish / 샘플 저장)
│   └── PedometerEventHandler.swift   # CMPedometer 스트림 → EventChannel
└── Model/
    ├── PedometerDataDTO.swift        # CMPedometer 데이터 → JSON
    ├── PedometerSample.swift         # HKQuantitySample (걸음수) 변환
    └── LocationSample.swift          # CLLocation + HKQuantitySample (거리) 변환
```

## 왜 HKWorkout을 사용했는가

### 단순 DB 저장 대신 HealthKit을 선택한 이유

러닝 데이터를 앱 내 로컬 DB(예: SQLite)에 저장하는 것도 가능하지만, 아래 이유로 HealthKit의 `HKWorkoutBuilder`를 선택했습니다.

**1. 플랫폼 표준 준수**
Apple Health는 iOS에서 건강/운동 데이터의 표준 저장소입니다. HealthKit에 저장하면 Strava, Nike Run Club 등 타 앱과 데이터를 공유할 수 있고, 사용자가 Apple Health 앱에서 직접 확인할 수 있습니다.

**2. HKWorkoutBuilder의 점진적 저장 구조**
`HKWorkoutBuilder`는 운동 중 샘플을 실시간으로 추가(`addSamples`)하고, 종료 시 `finishWorkout()`으로 확정하는 구조입니다. 앱이 강제 종료되더라도 중간까지의 데이터가 보존되는 내결함성이 있습니다.

**3. 다양한 샘플 타입 지원**
- `HKQuantitySample` (걸음수, 거리, 에너지 소모)
- `CLLocation` 배열 → `HKWorkoutRoute` (경로)
- `HKWorkoutEvent` (일시정지 / 재개 구간)

샘플들을 조합하여 Apple Health가 자동으로 운동 통계(페이스, 평균 속도 등)를 계산합니다.

**4. CMPedometer와의 조합**
CMPedometer는 iOS가 자체적으로 제공하는 걸음 감지 알고리즘으로, GPS보다 전력 소모가 적고 실내에서도 동작합니다. HealthKit에 걸음수 샘플을 저장하면 Apple Watch 데이터와도 통합됩니다.

### 배치 저장 방식 (5초 단위)

매 GPS 이벤트마다 MethodChannel을 호출하면 빈번한 플랫폼 통신으로 성능 저하가 발생합니다. 이를 방지하기 위해 Flutter 레이어에서 5초간 데이터를 버퍼링한 뒤 한 번의 MethodChannel 호출로 iOS에 배치 전송합니다.