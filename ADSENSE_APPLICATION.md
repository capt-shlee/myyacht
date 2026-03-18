# AdSense Application Runbook

## Scope

- Home (`/`) stays ad-free.
- `/jebu-tide/` stays ad-free.
- `/posts/` listing stays ad-free.
- `/about/`, `/contact/`, and `/privacy-policy/` stay ad-free.
- Only individual post pages under `/posts/...` may render ads after approval.

## Config switches

Edit `hugo.toml` or set environment variables before building:

- `params.adsense.account` or `HUGO_ADSENSE_ACCOUNT`
  - Accepts `ca-pub-...`.
  - The template also extracts `ca-pub-...` if the full AdSense meta tag snippet is pasted by mistake.
- `params.adsense.siteReview.enabled` or `HUGO_ADSENSE_SITE_REVIEW_ENABLED=true`
  - Adds `<meta name="google-adsense-account" ...>` to the global `<head>`.
- `params.adsense.adsTxt.enabled` or `HUGO_ADSENSE_ADS_TXT_ENABLED=true`
  - Publishes `/ads.txt` with the Google seller line when a valid account is present.
- `params.adsense.postsEnabled` or `HUGO_ADSENSE_POSTS_ENABLED=true`
  - Allows the AdSense script and slot rendering on post singles only.

## Application steps

1. Open AdSense.
2. Go to `Sites`.
3. Click `+ New site`.
4. Add `myyacht.kr`.
5. Choose the `Meta tag` method.
6. Copy the issued value into `params.adsense.account` or `HUGO_ADSENSE_ACCOUNT`.
7. Set `params.adsense.siteReview.enabled = true` or `HUGO_ADSENSE_SITE_REVIEW_ENABLED=true`.
8. Build and deploy.
9. Confirm the live `<head>` contains `google-adsense-account`.
10. In AdSense, tick verification complete and request review.
11. After approval, set `params.adsense.adsTxt.enabled = true`.
12. After approval, keep Auto ads excluded for `/`, `/jebu-tide/`, `/posts/`, `/about/`, `/contact/`, and `/privacy-policy/`.
13. After approval, enable `params.adsense.postsEnabled = true` only when post slot IDs are ready.

## Post-approval ad policy

- Do not add ads to the home landing.
- Do not add ads to `/jebu-tide/`.
- Do not add ads to policy or contact pages.
- Do not enable site-wide Auto ads without excluded pages.
- Keep manual ads limited to post singles.
