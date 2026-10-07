# Đăng ký khám chữa bệnh – App Flutter

Ứng dụng đặt lịch khám tại Trung tâm y tế, hỗ trợ BHYT. Có 6 vai trò: Bệnh nhân, Người giám hộ, Bác sĩ, Lễ tân, Thu ngân, Quản trị viên.
Nhóm: Duy · Lân · Thương · Hiếu · Hải.

---

## 1. Yêu cầu trên máy

| Phần mềm | Ghi chú |
|---|---|
| **Flutter** | Đúng phiên bản ghi trong file `.flutter-version` (kênh stable) |
| **Android Studio** | Cài Android SDK + 1 máy ảo. JDK dùng bản đi kèm Android Studio |
| **Git** | https://git-scm.com |
| **VS Code** | Cài 2 extension Dart, Flutter (VS Code tự gợi ý khi mở dự án) |

> ⚠️ Clone dự án vào thư mục **không dấu, không khoảng trắng**, ví dụ `C:\src\dang-ky-kham-benh`.
> Đường dẫn kiểu `C:\Users\Hải\Tài liệu\...` sẽ làm Gradle báo lỗi khi build Android.

## 2. Chạy lần đầu

```bash
git clone https://github.com/<username-hai>/dang-ky-kham-benh.git
cd dang-ky-kham-benh
```

- **Windows:** nhấp đúp `setup.bat`
- **macOS / Linux:** `chmod +x setup.sh && ./setup.sh`

Script sẽ kiểm tra phiên bản Flutter, chạy `flutter clean` + `flutter pub get` + `flutter doctor`. Sau đó:

```bash
flutter run
```

## 3. Lỗi thường gặp khi chạy trên máy khác

| Lỗi | Cách sửa |
|---|---|
| `version solving failed` / `requires SDK version` | Flutter khác phiên bản nhóm → đổi về đúng bản trong `.flutter-version` |
| `Unsupported class file major version` / lỗi Gradle liên quan Java | JDK không hợp. Chạy `flutter config --jdk-dir "<đường dẫn JDK 17 hoặc JDK của Android Studio>"` rồi `flutter clean` |
| `SDK location not found` / `local.properties` | Chạy `flutter pub get` (Flutter tự tạo lại file này, **không commit** nó) |
| Lỗi đường dẫn có ký tự lạ khi build | Chuyển dự án về thư mục không dấu, không khoảng trắng |
| Plugin báo cần `ndkVersion` khác | Chỉ **Hải** sửa `android/app/build.gradle(.kts)` theo đúng dòng gợi ý trong thông báo, commit lên main |
| Mọi lỗi lạ khác | `flutter clean` → `flutter pub get` → chạy lại. Vẫn lỗi thì chụp màn hình gửi nhóm |

## 4. Cấu trúc thư mục

```
lib/
  main.dart            (Hải)
  app/                 màu, chữ, theme, route tổng (Hải)
  core/widgets/        widget dùng chung (Hải)
  core/mock/           dữ liệu giả (Hải)
  models/              1 class / 1 bảng SQL (Hải)
  features/<module>/   màn hình của từng người – xem file phân công
```

## 5. Quy trình Git (tóm tắt)

```bash
git switch main
git pull origin main
git switch -c feature/<ten>-<chuc-nang>
# ... code ...
git add lib/features/<module-cua-ban>/
git commit -m "feat: mo ta ngan"
git push -u origin feature/<ten>-<chuc-nang>
```

Sau đó mở Pull Request vào `main` trên GitHub. GitHub sẽ tự build thử (tab **Checks**). Phải có **dấu tick xanh** thì Hải mới merge.

**Không** push thẳng lên `main`. **Không** sửa `main.dart`, `pubspec.yaml`, `lib/app`, `lib/core`, `lib/models`: nhắn Hải nếu cần.
