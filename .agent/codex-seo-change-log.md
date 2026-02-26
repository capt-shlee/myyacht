### 2026-02-24 (KST) - Deployment & Re-crawl Requests

- Change:
  - deployed themes/PaperMod/layouts/partials/head.html only
  - purpose: reduce duplicate description signal on taxonomy/category pages
- Re-crawl / indexing requests:
  - Naver: https://myyacht.kr/categories/
  - Google: https://myyacht.kr/categories/
  - Google: https://myyacht.kr/posts/
- Monitoring plan:
  - check in 2-3 days for indexing/status changes
  - keep SEO structure frozen unless critical issue appears

### 2026-02-26 (KST) - Legacy Redirect Stub Removal (404 normalization)

- Change:
  - removed static redirect stub files so deprecated URLs return 404
  - targets: /home/, /tour/, /club/, /contact/, /my-yacht-tour/, /my-yacht-club/, /tags/captains-log/
- Verification:
  - local Hugo build passed (`hugo`, `hugo --renderToMemory --panicOnWarning`)
  - generated output no longer contains those routes in `public/*`

### 2026-02-26 (KST) - 수항사 SEO 워크플로우 최신화 + 자동 점검 도입

- Change:
  - updated `.agent/수항사-지침서.md` with SERP metadata guide and automation policy
  - updated workflow docs:
    - `.agent/workflows/수항사-게시글발행.md`
    - `.agent/workflows/수항사-포스트기획.md`
    - `.agent/workflows/수항사-SEO유지보수.md`
  - added `scripts/seo-preflight.ps1` (pre-deploy SEO guard script)
- Verification:
  - executed `powershell -ExecutionPolicy Bypass -File scripts/seo-preflight.ps1 -BaseUrl https://myyacht.kr`
  - result: all checks passed (tags/localhost/sitemap/live 404 policy)

### 2026-02-26 (KST) - OG 메타 일관성/이미지 규격 지침 추가

- Change:
  - updated `.agent/수항사-지침서.md`
  - added policy to keep `meta description` and `og:description` aligned
  - added OG image standard: recommended `1200x630` (minimum `600x315`)

### 2026-02-26 (KST) - OG 이미지 자동화 스크립트 + og-main 규격 전환

- Change:
  - added `scripts/make-og-image.ps1` (contain 방식 1200x630 생성)
  - updated `.agent/수항사-지침서.md` with command example for OG generation
  - converted `static/images/og-main.jpg` to `1200x630`
  - backup created: `static/images/og-main-square-backup.jpg`
- Verification:
  - `public/images/og-main.jpg` confirmed as `1200x630`
  - `seo-preflight.ps1` run passed after update

### 2026-02-26 (KST) - categories 메타 설명/OG 설명 일치화

- Change:
  - updated `layouts/partials/templates/opengraph.html`
  - aligned og description fallback logic with head meta description logic for term/taxonomy/list contexts
- Verification:
  - `public/categories/index.html` check: `meta description` == `og:description` (MATCH)
  - `seo-preflight.ps1` run passed
