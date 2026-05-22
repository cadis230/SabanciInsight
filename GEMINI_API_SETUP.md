# Gemini API — team setup (easy)

The project uses a **shared team API key** in the template file. Teammates do **not** need to create their own Google AI Studio key.

## After `git clone` (3 steps)

```powershell
cd SabanciInsight
flutter pub get
.\setup_gemini_key.ps1
flutter run
```

That is all. AI summaries should work on courses that have reviews.

## If AI still fails

- Run `.\setup_gemini_key.ps1` again (recreates `gemini_api_key.local.dart`).
- Check you are logged in with `@sabanciuniv.edu`.
- Key may be expired or quota full — ask the team lead or check [AI Studio Rate Limit](https://aistudio.google.com/).

## For the team lead (you)

- Key lives in `lib/config/gemini_api_key.local.example.dart` (committed for private team repos).
- **Keep the GitHub repository PRIVATE.** Never push this to a public repo.
- If the key leaks, revoke it in AI Studio and update the `.example.dart` file.

## Optional: own key instead

Replace the value in `lib/config/gemini_api_key.local.dart` with your personal key from [AI Studio](https://aistudio.google.com/app/apikey).
