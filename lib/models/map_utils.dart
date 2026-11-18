import 'package:cloud_firestore/cloud_firestore.dart';

/// Đọc ngày từ Map. Quy ước nhóm: ngày lưu trên Firestore là chuỗi ISO
/// (do `toMap()` tạo ra). Vẫn đọc được Timestamp phòng khi ai đó sửa tay
/// trên Firebase console hoặc dùng FieldValue.serverTimestamp().
DateTime parseDate(Object? v) {
  if (v is DateTime) return v;
  if (v is Timestamp) return v.toDate();
  if (v is String) return DateTime.parse(v);
  throw ArgumentError('Không đọc được ngày: $v');
}

DateTime? parseDateOrNull(Object? v) => v == null ? null : parseDate(v);
