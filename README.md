# SmartNote - 똑똑이 노트

<br>

갖고있는 이미지 또는 찍은 사진에 담긴 텍스트를 추출하여 복사해서 바로 메모로 작성할 수 있고 특정언어로 번역하여 저장할 수 있는 앱

Simple!  Take a photo -> App will extract text from photos -> Copy text to Memo -> Can translate it to other language.



- 개요 : 찍거나 불러온 사진에 담겨있는 텍스트를 추출하여 메모로 저장 및 공유할 수 있으며, 다른 언어로 번역해 저장할 수 있는 앱으로

​      이틀간 짧게 완성했던 토이프로젝트

- 참여 인원 : iOS 2명
- 담당 구현 파트
  - 메인 메모 작성 페이지, Custom 카메라 페이지, 카메라 촬영 결과 페이지
  - Google Cloud Vision API를 통한 촬영한 사진이나 앨범 사진에 담겨있는 텍스트 추출 기능
  - Kakao 번역 API를 통한 텍스트 번역 기능
  - CoreData를 이용하여 추출한 텍스트를 앱 내 저장
  - 저장한 메모 잠금, 수정, 삭제 기능
  - FSCalendar 오픈소스 캘린더 UI 및 기능 개선
- 사용 기술 : Swift, Google Cloud Vision API, Kakao 번역 API, CoreData, Git, GitHub
- Github Link : https://github.com/AlexLee365/SmartNote
- 시연 영상 : https://www.youtube.com/watch?v=c3-iKhdcI7s&t=0s