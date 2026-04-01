# AGENTS.md

## Default Publishing Rule
- 모든 `content/posts/**/index.md` 신규 작성/수정 작업은 사용자 요청이 없어도 SEO 기본 점검을 수행한다.

## Image Handling
- Do not crop photos without explicit user approval.
- Default to showing the full image.
- If cropping would improve layout, ask first and explain the tradeoff.

## SEO Baseline Checklist
- Front matter 필수 항목 확인: `title`, `summary`, `description`, `categories`, `keywords`, `cover.image`, `cover.alt`
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
