# Programmatically modifying a Google Sheet

Sheet ID used in examples: `1sljH3i1vOrzK-OhpudAnNMJxT0WcSGEepUDljZGyo4o`
(replace with your own sheet's ID — the long string in the sheet's URL)

## Option 1: Google Apps Script (zero setup, runs in the browser)

No credentials or API keys needed — it's built into the sheet. In the sheet:
**Extensions → Apps Script**, then:

```javascript
function updateSheet() {
  const ss = SpreadsheetApp.openById('1sljH3i1vOrzK-OhpudAnNMJxT0WcSGEepUDljZGyo4o');
  const sheet = ss.getSheetByName('Sheet1');
  sheet.getRange('A1').setValue('Hello from script');
  sheet.getRange('A2:C2').setValues([['a', 'b', 'c']]);
  sheet.appendRow([new Date(), 'appended row']);
}
```

Click **Run** (first run asks for authorization). You can also add triggers
(clock icon) to run it on a schedule, or expose it as a web endpoint via
`doPost`. To drive it from your terminal, use `clasp` (npm) to push code and
run functions from the CLI (requires the Apps Script API).

## Option 2: Python with `gspread` (best for local scripting)

1. **One-time setup** at <https://console.cloud.google.com> (free):
   - Create a project → **APIs & Services → Enable** the **Google Sheets API**
     and **Drive API**
   - **Credentials → Create credentials → OAuth client ID → Desktop app** →
     download the JSON, save as `~/.config/gspread/credentials.json`
     (needed because Google now blocks the old gcloud-style default client for
     sensitive scopes)
2. Install and run:

   ```bash
   pip install gspread
   ```

```python
import gspread

gc = gspread.oauth()  # opens browser once on first run, then caches tokens
sh = gc.open_by_key('1sljH3i1vOrzK-OhpudAnNMJxT0WcSGEepUDljZGyo4o')
ws = sh.sheet1

ws.update_acell('A1', 'Hello from Python')          # single cell
ws.update('A2:C2', [['a', 'b', 'c']])               # range
ws.append_row(['2026-09-04', 'new row'])            # append
rows = ws.get_all_values()                          # read everything
```

Sign in as `anssip@gmail.com` (owner) or `anssi.piirainen@amatechs.com`
(editor) during the first browser prompt — either works for edits.

## Option 3: Raw REST with curl

Once you have a token with the `spreadsheets` scope (e.g. from Option 2's
OAuth flow, or a service account):

```bash
curl -s -X PUT \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"values": [["Hello", "World"], ["row2col1", "row2col2"]]}' \
  "https://sheets.googleapis.com/v4/spreadsheets/1sljH3i1vOrzK-OhpudAnNMJxT0WcSGEepUDljZGyo4o/values/Sheet1!A1:B2?valueInputOption=USER_ENTERED"
```

## Recommendation

- Quick jobs and scheduled automation → **Option 1** (nothing to install or
  authenticate)
- Driven from the Mac terminal or your own scripts → **Option 2**
