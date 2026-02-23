# Codex Notes (Read Me First)

## 2026-02-23

### Summary
- SEO 제외요청 대상 URL 점검 및 정리.
- `/HOME`, `/문의`, `/my-YACHT-Club`, `/my-YACHT-Tour` alias 제거 후 404 확인 완료.
- tags taxonomy 비활성화로 `/tags/*` 페이지 생성 중단.
- `.agent`용 프롬프트 가이드 제공: 글 생성 시 `tags` 필드 제거.
- 한글 파일 저장 시 UTF-8 인코딩 명시 규칙 추가.

### Status Checks (Result = 404)
- `https://myyacht.kr/HOME`
- `https://myyacht.kr/HOME/`
- `https://myyacht.kr/문의`
- `https://myyacht.kr/문의/`
- `https://myyacht.kr/my-YACHT-Club`
- `https://myyacht.kr/my-YACHT-Club/`
- `https://myyacht.kr/my-YACHT-Tour`
- `https://myyacht.kr/my-YACHT-Tour/`

### Files Changed
- `content/_index.md`
  - Removed aliases: `/HOME`, `/my-YACHT-Club`, `/my-YACHT-Tour`, `/문의`
  - Rewrote front matter with valid UTF-8 Korean text
- `hugo.toml`
  - Added:
    - `[taxonomies]`
    - `category = "categories"`
  - Effect: disables `tags` taxonomy generation

### Notes
- tags taxonomy 비활성화 후 기존 태그 URL들은 404로 처리됨.
- 검색 제외 요청은 삭제된 URL(404/410/403) 기준으로 진행.
- 한글 파일 저장/수정 시 반드시 `UTF-8` 인코딩을 명시. (예: `Set-Content -Encoding utf8`)
