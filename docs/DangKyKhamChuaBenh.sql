CREATE DATABASE DangKyKhamChuaBenh;
GO
USE DangKyKhamChuaBenh;
GO

-- 0. DANH MỤC VAI TRÒ
CREATE TABLE DM_VaiTro (
    MaVaiTro        INT IDENTITY(1,1)   PRIMARY KEY,
    TenVaiTro       NVARCHAR(30)        NOT NULL UNIQUE,
    MoTa            NVARCHAR(255)       NULL
);
GO

INSERT INTO DM_VaiTro (TenVaiTro, MoTa) VALUES
(N'Bệnh nhân',      N'Tự đặt lịch khám, có hồ sơ bản thân'),
(N'Người giám hộ',  N'Không có hồ sơ bản thân, chỉ quản lý hồ sơ người thân'),
(N'Bác sĩ',         N'Khám bệnh, cập nhật kết quả khám'),
(N'Lễ tân',         N'Check-in bệnh nhân bằng mã QR'),
(N'Thu ngân',       N'Xử lý thanh toán, xuất hóa đơn'),
(N'Quản trị viên',  N'Quản lý danh mục, tài khoản, thống kê');
GO

-- 1. TÀI KHOẢN
CREATE TABLE TaiKhoan (
    MaTaiKhoan      INT IDENTITY(1,1)   PRIMARY KEY,
    SoDienThoai     VARCHAR(15)         NOT NULL UNIQUE,
    Email           VARCHAR(100)        NULL UNIQUE,
    MatKhauHash     VARBINARY(256)      NOT NULL,
    HoTen           NVARCHAR(100)       NOT NULL,
    MaVaiTro        INT                 NOT NULL,
    TrangThai       TINYINT             NOT NULL DEFAULT 1,
    NgayTao         DATETIME            NOT NULL DEFAULT GETDATE(),
    NgayCapNhat     DATETIME            NULL,
    CONSTRAINT FK_TaiKhoan_VaiTro
        FOREIGN KEY (MaVaiTro) REFERENCES DM_VaiTro(MaVaiTro)
);
GO

-- 2. BỆNH NHÂN
CREATE TABLE BenhNhan (
    MaBenhNhan          INT IDENTITY(1,1)   PRIMARY KEY,
    MaTaiKhoanQuanLy    INT                 NOT NULL,
    MoiQuanHe           NVARCHAR(30)        NOT NULL DEFAULT N'Bản thân'
        CHECK (MoiQuanHe IN (N'Bản thân', N'Con', N'Cha/Mẹ', N'Vợ/Chồng', N'Người thân khác')),
    HoTen               NVARCHAR(100)       NOT NULL,
    NgaySinh            DATE                NOT NULL,
    GioiTinh            NVARCHAR(10)        NOT NULL
        CHECK (GioiTinh IN (N'Nam', N'Nữ', N'Khác')),
    SoCCCD              VARCHAR(12)         NULL UNIQUE,
    DiaChi              NVARCHAR(255)       NULL,
    NgayTao             DATETIME            NOT NULL DEFAULT GETDATE(),
    NgayCapNhat         DATETIME            NULL,
    CONSTRAINT FK_BenhNhan_TaiKhoan
        FOREIGN KEY (MaTaiKhoanQuanLy) REFERENCES TaiKhoan(MaTaiKhoan)
);
GO

-- 3. THẺ BHYT
CREATE TABLE TheBHYT (
    MaBHYT                  INT IDENTITY(1,1)   PRIMARY KEY,
    MaBenhNhan              INT                 NOT NULL,
    SoTheBHYT               VARCHAR(20)         NOT NULL UNIQUE,
    NoiDangKyKCBBanDau      NVARCHAR(255)       NOT NULL,
    NgayHieuLuc             DATE                NOT NULL,
    NgayHetHan              DATE                NOT NULL,
    MucHuongBHYT            TINYINT             NOT NULL DEFAULT 80,
    NgayTao                 DATETIME            NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_TheBHYT_BenhNhan
        FOREIGN KEY (MaBenhNhan) REFERENCES BenhNhan(MaBenhNhan),
    CONSTRAINT CK_TheBHYT_NgayHan CHECK (NgayHetHan > NgayHieuLuc)
);
GO

-- 4. CƠ SỞ Y TẾ
CREATE TABLE CoSoYTe (
    MaCoSo          INT IDENTITY(1,1)   PRIMARY KEY,
    TenCoSo         NVARCHAR(150)       NOT NULL,
    DiaChi          NVARCHAR(255)       NOT NULL,
    SoDienThoai     VARCHAR(15)         NULL,
    LoaiCoSo        NVARCHAR(50)        NULL,
    HoTroBHYT       BIT                 NOT NULL DEFAULT 1,
    TrangThai       BIT                 NOT NULL DEFAULT 1,
    NgayTao         DATETIME            NOT NULL DEFAULT GETDATE()
);
GO

-- 5. NHÂN VIÊN
CREATE TABLE NhanVien (
    MaNhanVien      INT IDENTITY(1,1)   PRIMARY KEY,
    MaTaiKhoan      INT                 NOT NULL UNIQUE,
    MaCoSo          INT                 NULL,
    NgayVaoLam      DATE                NULL,
    GhiChu          NVARCHAR(255)       NULL,
    NgayTao         DATETIME            NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_NhanVien_TaiKhoan
        FOREIGN KEY (MaTaiKhoan) REFERENCES TaiKhoan(MaTaiKhoan),
    CONSTRAINT FK_NhanVien_CoSo
        FOREIGN KEY (MaCoSo) REFERENCES CoSoYTe(MaCoSo)
);
GO

-- 6. CHUYÊN KHOA
CREATE TABLE ChuyenKhoa (
    MaChuyenKhoa    INT IDENTITY(1,1)   PRIMARY KEY,
    MaCoSo          INT                 NOT NULL,
    TenChuyenKhoa   NVARCHAR(100)       NOT NULL,
    MoTa            NVARCHAR(255)       NULL,
    GiaKhamCoBan    DECIMAL(12,0)       NOT NULL DEFAULT 0,
    TrangThai       BIT                 NOT NULL DEFAULT 1,
    NgayTao         DATETIME            NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_ChuyenKhoa_CoSo
        FOREIGN KEY (MaCoSo) REFERENCES CoSoYTe(MaCoSo)
);
GO

-- 7. BÁC SĨ
CREATE TABLE BacSi (
    MaBacSi         INT IDENTITY(1,1)   PRIMARY KEY,
    MaTaiKhoan      INT                 NULL UNIQUE,
    MaChuyenKhoa    INT                 NOT NULL,
    HoTen           NVARCHAR(100)       NOT NULL,
    HocHamHocVi     NVARCHAR(50)        NULL,
    SoDienThoai     VARCHAR(15)         NULL,
    AnhDaiDien      VARCHAR(255)        NULL,
    DiemDanhGiaTB   DECIMAL(3,2)        NOT NULL DEFAULT 0,
    TrangThai       BIT                 NOT NULL DEFAULT 1,
    NgayTao         DATETIME            NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_BacSi_TaiKhoan
        FOREIGN KEY (MaTaiKhoan) REFERENCES TaiKhoan(MaTaiKhoan),
    CONSTRAINT FK_BacSi_ChuyenKhoa
        FOREIGN KEY (MaChuyenKhoa) REFERENCES ChuyenKhoa(MaChuyenKhoa)
);
GO

-- 8. LỊCH LÀM VIỆC
CREATE TABLE LichLamViec (
    MaLich          INT IDENTITY(1,1)   PRIMARY KEY,
    MaBacSi         INT                 NOT NULL,
    Ngay            DATE                NOT NULL,
    GioBatDau       TIME                NOT NULL,
    GioKetThuc      TIME                NOT NULL,
    SoLuongCho      INT                 NOT NULL DEFAULT 1,
    SoLuongDaDat    INT                 NOT NULL DEFAULT 0,
    TrangThai       TINYINT             NOT NULL DEFAULT 1,
    NgayTao         DATETIME            NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_LichLamViec_BacSi
        FOREIGN KEY (MaBacSi) REFERENCES BacSi(MaBacSi),
    CONSTRAINT CK_LichLamViec_SoLuong CHECK (SoLuongDaDat <= SoLuongCho),
    CONSTRAINT CK_LichLamViec_GioKham CHECK (GioKetThuc > GioBatDau),
    CONSTRAINT UQ_LichLamViec_TrungLich UNIQUE (MaBacSi, Ngay, GioBatDau)
);
GO

-- 9. ĐẶT LỊCH KHÁM
CREATE TABLE DatLich (
    MaDatLich       INT IDENTITY(1,1)   PRIMARY KEY,
    MaBenhNhan      INT                 NOT NULL,
    DatBoi          INT                 NOT NULL,
    MaLich          INT                 NOT NULL,
    HinhThucKham    NVARCHAR(20)        NOT NULL
        CHECK (HinhThucKham IN (N'BHYT', N'Không BHYT')),
    MaBHYT          INT                 NULL,
    LyDoKham        NVARCHAR(255)       NULL,
    MaXacNhan       VARCHAR(20)         NOT NULL UNIQUE,
    TrangThai       NVARCHAR(20)        NOT NULL DEFAULT N'Chờ thanh toán'
        CHECK (TrangThai IN (N'Chờ thanh toán', N'Đã thanh toán', N'Đã đến',
                              N'Đã khám', N'Không đến', N'Hoãn', N'Đã hủy')),
    NgayDat         DATETIME            NOT NULL DEFAULT GETDATE(),
    CapNhatBoi      INT                 NULL,
    NgayCapNhat     DATETIME            NULL,
    CONSTRAINT FK_DatLich_BenhNhan
        FOREIGN KEY (MaBenhNhan) REFERENCES BenhNhan(MaBenhNhan),
    CONSTRAINT FK_DatLich_DatBoi
        FOREIGN KEY (DatBoi) REFERENCES TaiKhoan(MaTaiKhoan),
    CONSTRAINT FK_DatLich_LichLamViec
        FOREIGN KEY (MaLich) REFERENCES LichLamViec(MaLich),
    CONSTRAINT FK_DatLich_TheBHYT
        FOREIGN KEY (MaBHYT) REFERENCES TheBHYT(MaBHYT),
    CONSTRAINT FK_DatLich_CapNhatBoi
        FOREIGN KEY (CapNhatBoi) REFERENCES TaiKhoan(MaTaiKhoan)
);
GO

-- 10. THANH TOÁN
CREATE TABLE ThanhToan (
    MaThanhToan     INT IDENTITY(1,1)   PRIMARY KEY,
    MaDatLich       INT                 NOT NULL UNIQUE,
    SoTien          DECIMAL(12,0)       NOT NULL,
    PhuongThuc      NVARCHAR(30)        NOT NULL
        CHECK (PhuongThuc IN (N'Tiền mặt', N'Chuyển khoản', N'Ví điện tử')),
    TrangThai       NVARCHAR(20)        NOT NULL DEFAULT N'Chưa thanh toán'
        CHECK (TrangThai IN (N'Chưa thanh toán', N'Đã thanh toán', N'Đã hoàn tiền')),
    NgayThanhToan   DATETIME            NULL,
    XuLyBoi         INT                 NULL,
    CONSTRAINT FK_ThanhToan_DatLich
        FOREIGN KEY (MaDatLich) REFERENCES DatLich(MaDatLich),
    CONSTRAINT FK_ThanhToan_XuLyBoi
        FOREIGN KEY (XuLyBoi) REFERENCES TaiKhoan(MaTaiKhoan)
);
GO

-- 11. HÓA ĐƠN
CREATE TABLE HoaDon (
    MaHoaDon        INT IDENTITY(1,1)   PRIMARY KEY,
    MaThanhToan     INT                 NOT NULL UNIQUE,
    SoHoaDon        VARCHAR(20)         NOT NULL UNIQUE,
    NgayXuat        DATETIME            NOT NULL DEFAULT GETDATE(),
    XuatBoi         INT                 NOT NULL,
    CONSTRAINT FK_HoaDon_ThanhToan
        FOREIGN KEY (MaThanhToan) REFERENCES ThanhToan(MaThanhToan),
    CONSTRAINT FK_HoaDon_XuatBoi
        FOREIGN KEY (XuatBoi) REFERENCES TaiKhoan(MaTaiKhoan)
);
GO

-- 12. ĐÁNH GIÁ
CREATE TABLE DanhGia (
    MaDanhGia       INT IDENTITY(1,1)   PRIMARY KEY,
    MaDatLich       INT                 NOT NULL UNIQUE,
    NguoiDanhGia    INT                 NOT NULL,
    SoSao           TINYINT             NOT NULL CHECK (SoSao BETWEEN 1 AND 5),
    NhanXet         NVARCHAR(500)       NULL,
    NgayDanhGia     DATETIME            NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_DanhGia_DatLich
        FOREIGN KEY (MaDatLich) REFERENCES DatLich(MaDatLich),
    CONSTRAINT FK_DanhGia_NguoiDanhGia
        FOREIGN KEY (NguoiDanhGia) REFERENCES TaiKhoan(MaTaiKhoan)
);
GO

-- 13. THÔNG BÁO
CREATE TABLE ThongBao (
    MaThongBao      INT IDENTITY(1,1)   PRIMARY KEY,
    MaDatLich       INT                 NOT NULL,
    LoaiThongBao    NVARCHAR(20)        NOT NULL
        CHECK (LoaiThongBao IN (N'Xác nhận', N'Nhắc lịch', N'Hủy lịch', N'Thanh toán')),
    NoiDung         NVARCHAR(500)       NOT NULL,
    KenhGui         NVARCHAR(20)        NOT NULL DEFAULT N'Ứng dụng'
        CHECK (KenhGui IN (N'Ứng dụng', N'SMS', N'Email')),
    ThoiGianGui     DATETIME            NOT NULL DEFAULT GETDATE(),
    DaDoc           BIT                 NOT NULL DEFAULT 0,
    CONSTRAINT FK_ThongBao_DatLich
        FOREIGN KEY (MaDatLich) REFERENCES DatLich(MaDatLich)
);
GO

-- 14. NHẬT KÝ QUẢN TRỊ
CREATE TABLE NhatKyQuanTri (
    MaNhatKy        INT IDENTITY(1,1)   PRIMARY KEY,
    MaTaiKhoan      INT                 NOT NULL,
    HanhDong        NVARCHAR(255)       NOT NULL,
    ThoiGian        DATETIME            NOT NULL DEFAULT GETDATE(),
    GhiChu          NVARCHAR(500)       NULL,
    CONSTRAINT FK_NhatKyQuanTri_TaiKhoan
        FOREIGN KEY (MaTaiKhoan) REFERENCES TaiKhoan(MaTaiKhoan)
);
GO

-- CHỈ MỤC
CREATE INDEX IX_TaiKhoan_VaiTro          ON TaiKhoan(MaVaiTro);
CREATE INDEX IX_BenhNhan_TaiKhoanQuanLy  ON BenhNhan(MaTaiKhoanQuanLy);
CREATE INDEX IX_NhanVien_CoSo            ON NhanVien(MaCoSo);
CREATE INDEX IX_ChuyenKhoa_CoSo          ON ChuyenKhoa(MaCoSo);
CREATE INDEX IX_BacSi_ChuyenKhoa         ON BacSi(MaChuyenKhoa);
CREATE INDEX IX_LichLamViec_BacSi_Ngay   ON LichLamViec(MaBacSi, Ngay);
CREATE INDEX IX_DatLich_BenhNhan         ON DatLich(MaBenhNhan);
CREATE INDEX IX_DatLich_DatBoi           ON DatLich(DatBoi);
CREATE INDEX IX_DatLich_MaXacNhan        ON DatLich(MaXacNhan);
CREATE INDEX IX_ThanhToan_DatLich        ON ThanhToan(MaDatLich);
CREATE INDEX IX_DanhGia_DatLich          ON DanhGia(MaDatLich);
CREATE INDEX IX_ThongBao_DatLich         ON ThongBao(MaDatLich);
GO

-- TRIGGER 1: tăng SoLuongDaDat khi có lịch đặt mới
CREATE TRIGGER trg_DatLich_CapNhatSoLuong
ON DatLich
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE ll
    SET ll.SoLuongDaDat = ll.SoLuongDaDat + 1,
        ll.TrangThai = CASE WHEN ll.SoLuongDaDat + 1 >= ll.SoLuongCho THEN 0 ELSE 1 END
    FROM LichLamViec ll
    INNER JOIN inserted i ON ll.MaLich = i.MaLich;
END;
GO

-- TRIGGER 2: giải phóng chỗ + hoàn tiền khi hủy lịch
CREATE TRIGGER trg_DatLich_HuyLich
ON DatLich
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(TrangThai)
    BEGIN
        UPDATE ll
        SET ll.SoLuongDaDat = ll.SoLuongDaDat - 1,
            ll.TrangThai = 1
        FROM LichLamViec ll
        INNER JOIN inserted i ON ll.MaLich = i.MaLich
        INNER JOIN deleted d ON d.MaDatLich = i.MaDatLich
        WHERE i.TrangThai = N'Đã hủy' AND d.TrangThai <> N'Đã hủy';

        UPDATE tt
        SET tt.TrangThai = N'Đã hoàn tiền'
        FROM ThanhToan tt
        INNER JOIN inserted i ON tt.MaDatLich = i.MaDatLich
        INNER JOIN deleted d ON d.MaDatLich = i.MaDatLich
        WHERE i.TrangThai = N'Đã hủy' AND d.TrangThai <> N'Đã hủy'
              AND tt.TrangThai = N'Đã thanh toán';
    END
END;
GO

-- TRIGGER 3: cập nhật điểm đánh giá trung bình của bác sĩ
CREATE TRIGGER trg_DanhGia_CapNhatDiemBacSi
ON DanhGia
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE bs
    SET bs.DiemDanhGiaTB = tb.DiemTB
    FROM BacSi bs
    INNER JOIN LichLamViec ll ON ll.MaBacSi = bs.MaBacSi
    INNER JOIN DatLich dl ON dl.MaLich = ll.MaLich
    INNER JOIN inserted i ON i.MaDatLich = dl.MaDatLich
    CROSS APPLY (
        SELECT AVG(CAST(dg.SoSao AS DECIMAL(3,2))) AS DiemTB
        FROM DanhGia dg
        INNER JOIN DatLich dl2 ON dl2.MaDatLich = dg.MaDatLich
        INNER JOIN LichLamViec ll2 ON ll2.MaLich = dl2.MaLich
        WHERE ll2.MaBacSi = bs.MaBacSi
    ) tb;
END;
GO
