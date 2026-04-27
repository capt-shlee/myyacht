# AGENTS.md

## Default Publishing Rule
- 모든 `content/posts/**/index.md` 신규 작성/수정 작업은 사용자 요청이 없어도 SEO 기본 점검을 수행한다.

## Change Logging
- 랜딩 페이지, SEO, 운영 문구, 주소 등 사이트 반영 변경사항은 `SEO_CHANGELOG.md`에 날짜별(`YYYY-MM-DD`)로 기록한다.
- 사용자가 별도 금지하지 않는 한, 실제 반영 변경이 있으면 작업 마무리 전 해당 날짜 섹션에 요약을 추가한다.

## Image Handling
- Do not crop photos without explicit user approval.
- Default to showing the full image.
- If cropping would improve layout, ask first and explain the tradeoff.

## SEO Baseline Checklist
- Front matter 필수 항목 확인: `title`, `summary`, `description`, `keywords`, `cover.image`, `cover.alt`
- `categories`/`tags`는 사용하지 않는다. 기존 글 수정 시 발견하면 제거한다.
- 가능하면 `seoTitle` 포함 (검색 의도 키워드 1개 이상 포함)
- 메타 길이 권장:
  - `title`: 25~60자
  - `summary`: 60~140자
  - `description`: 70~160자
- 본문 첫 2~3문단 안에 핵심 키워드 자연 포함
- 이미지가 있는 글은 대표 썸네일(권장 1200x630) 준비 및 `cover.image` 연결
- 이미지 `alt`는 장면 설명형 문장으로 작성
- 내부 문서 링크(관련 글) 1~3개 포함 권장
- 맞춤법/오탈자 빠른 점검 후 저장

## Writing Revision Preferences
- 글 수정 요청을 받으면 개별 문장만 고치지 말고 본문 전체를 다시 읽고 구조, 순서, 중복, 톤을 한 번에 점검한다.
- 사용자가 몇 가지 수정 포인트만 줘도 그 항목만 반영하고 끝내지 말고, 글 전체 맥락에서 어색한 문장과 흐름까지 함께 정리한다.
- 보고체, 작업일지체, 사용자에게 설명하듯 말하는 문장, 당연한 안전 상식 설명은 기본적으로 피한다.
- 목표는 "사람이 쓴 자연스러운 글"이다. 초안이라도 부분 패치보다 전체 흐름을 먼저 잡고 한 번에 마무리하는 방향을 우선한다.
- `Q&A`/`FAQ`/`FAQPage` 스키마는 기본값이 아니다. 글 성격이 실제로 질문형 검색 의도에 강하게 맞을 때만 사용한다.
- 영업 연결이나 CTA는 기본적으로 넣지 않는다. 서비스 운영과의 연결이 글의 실제 결론일 때만, 과장 없이 "운영상 체감 변화" 수준으로 자연스럽게 녹인다.
- 영업 연결을 넣는 경우에는 본문 한 문단만 추가하지 말고 `seoTitle`, `summary`, `description`, 헤더 구조까지 함께 재점검한다.
- 최종 저장 전에는 반드시 처음부터 끝까지 한 번 더 읽고, 억지 SEO/AEO 문장이나 문체 튐이 없는지 확인한다.

## Validation
- 수정 후 `hugo --printPathWarnings`로 빌드 검증
- 빌드 오류/경고가 있으면 배포 전 수정

## Draft Handling
- `draft` 값은 사용자가 발행 지시하기 전까지 유지
- 사용자가 발행/배포를 요청하면 `draft: false` 전환 여부를 먼저 확인하고 진행

## Publish Time Guardrail
- 사용자가 "배포"를 요청하면 대상 글의 `date`가 현재 시각(기본 `Asia/Seoul`)보다 미래인지 반드시 점검한다.
- `date`가 미래이면 배포 전에 현재 시각 이전으로 조정하거나, 사용자에게 확인 후 진행한다.
- 배포 직전 최종 체크: `draft: false` + `date <= now(Asia/Seoul)`.
