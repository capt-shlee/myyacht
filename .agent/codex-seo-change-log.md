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
