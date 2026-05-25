/// Formats a [DateTime] as an ISO-style date string `YYYY-MM-DD`.
/// Used for Firestore date-keyed availability maps.
String fmtDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
