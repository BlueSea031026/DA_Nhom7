/// Đọc ngày từ Map. Hiện dữ liệu giả dùng DateTime/chuỗi ISO.
/// Khi nối Firestore: thêm nhánh `if (v is Timestamp) return v.toDate();`
DateTime parseDate(Object? v) {
  if (v is DateTime) return v;
  if (v is String) return DateTime.parse(v);
  throw ArgumentError('Không đọc được ngày: $v');
}

DateTime? parseDateOrNull(Object? v) => v == null ? null : parseDate(v);
