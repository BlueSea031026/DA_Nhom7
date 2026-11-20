/// Bỏ dấu tiếng Việt + chữ thường để tìm kiếm "nguyen" ra "Nguyễn".
/// Phụ trách: Thương
String boDau(String input) {
  const String co =
      'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ';
  const String khong =
      'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd';
  final StringBuffer kq = StringBuffer();
  for (final String ch in input.toLowerCase().split('')) {
    final int i = co.indexOf(ch);
    kq.write(i >= 0 ? khong[i] : ch);
  }
  return kq.toString();
}

/// true nếu [noiDung] chứa [tuKhoa] (không phân biệt hoa thường, dấu).
bool khop(String noiDung, String tuKhoa) =>
    boDau(noiDung).contains(boDau(tuKhoa.trim()));
