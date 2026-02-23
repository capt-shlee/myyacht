# SEO Change Log

목적: 순위 변동 원인을 추적 가능하게 만들기 위해, SEO 영향 변경을 배포 단위로 기록한다.

## 1) 운영 원칙

- 한 번에 하나만: `가설 1개 = 변경 1개 = 배포 1번`
- 관찰 시간: 배포 후 최소 `48~72시간`은 추가 SEO 변경 금지
- 디자인 변경과 SEO 변경 분리 배포
- SEO 영향 파일은 반드시 체크리스트 통과 후 배포

## 2) SEO 영향 파일(관리 대상)

- `hugo.toml`
- `static/robots.txt`
- `layouts/partials/templates/opengraph.html`
- `layouts/partials/templates/twitter_cards.html`
- `layouts/partials/templates/schema_json.html`
- `layouts/partials/extend_head.html`
- `layouts/_default/single.html`

## 3) 배포 전 체크리스트

### A. robots/sitemap

- [ ] `static/robots.txt` 정책이 의도와 일치 (`Allow/Disallow`)
- [ ] `Sitemap: https://myyacht.kr/sitemap.xml` 존재
- [ ] `hugo.toml`의 `enableRobotsTXT` 값이 현재 운영 정책과 충돌하지 않음

### B. canonical/OG/Twitter

- [ ] canonical이 절대 URL로 출력됨 (`https://myyacht.kr/...`)
- [ ] `og:url`이 canonical과 일치
- [ ] `og:image`/`twitter:image`가 절대 URL
- [ ] 메타에 `localhost`/로컬 주소 없음

### C. schema (JSON-LD)

- [ ] 홈 `LocalBusiness` JSON-LD 유효
- [ ] 한글 필드 깨짐 없음 (예: `?쒕`, `�` 없음)
- [ ] 주소/상호명 필수 필드 정상

### D. 인덱싱 신호

- [ ] 홈(`/`) 응답 코드 `200`
- [ ] `robots.txt` 응답 코드 `200`
- [ ] `sitemap.xml` 응답 코드 `200`
- [ ] 의도치 않은 `noindex` 없음

## 4) 빠른 점검 명령(로컬/배포 후)

```powershell
# robots/sitemap
curl.exe -I https://myyacht.kr/robots.txt
curl.exe -I https://myyacht.kr/sitemap.xml

# 홈 헤드 핵심 신호
$html = curl.exe -s https://myyacht.kr/
$html | Select-String -SimpleMatch 'rel=canonical','property="og:url"','name=twitter:card','application/ld+json','localhost','noindex'

# schema 한글 깨짐 패턴 확인
$html | Select-String -SimpleMatch '?쒕','�','MyYacht 제부도 요트 투어','경기도 화성시 서신면 해안길 477 (제부 마리나)'
```

## 5) 변경 로그 템플릿

```md
### YYYY-MM-DD HH:mm (KST)

- 변경 ID(커밋): 
- 변경 유형: [SEO | 디자인 | 콘텐츠 | 인프라]
- 변경 파일:
  - 
- 가설(왜 바꾸는가):
- 예상 효과(상승/하락 가능성 포함):
- 배포 시각:
- 배포 후 즉시 점검:
  - [ ] robots 200
  - [ ] sitemap 200
  - [ ] canonical/og:url 일치
  - [ ] schema 한글 정상
- 24h 관찰:
- 48h 관찰:
- 72h 관찰:
- 결론(유효/무효/추가실험):
```

## 6) 최근 이슈 메모

- 2026-02-21: `schema_json.html`의 홈 `LocalBusiness` 한글 문자열 깨짐 이슈 발생
- 대응: `name`, `streetAddress` 복구 후 재배포 및 재수집 요청

## 7) 실행 로그

### 2026-02-23 (KST)

- 변경 유형: `운영(검색 정리 및 태그 비활성화)`
- 작업:
  - `hugo.toml`에서 `tags` taxonomy 비활성화 반영
  - 에이전트 지침(`.agent`) 전수 업데이트: 모든 글에서 `tags` 필드 제거 규칙 적용
  - 네이버 `검색제외요청`에 기존 인덱싱된 `/tags/` 경로 일부 등록 진행
- 관찰 계획:
  - 24h: 태그 페이지 제거에 따른 404 발생 현황 모니터링
  - 72h: 색인 정리 상태 및 주요 키워드 순위 변동 확인
