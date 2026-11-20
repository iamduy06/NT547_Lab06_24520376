# NT547 - LAB 06 - BÁO CÁO (TỰ ĐIỀN)

**MSSV:** 24520376  | **Họ tên:** Huỳnh Thanh Duy | **Lớp:** NT547.R11.ANTT
**Session code tự sinh:** SC-9D2362 | **Tên contract:** Escrow_0376
**Solidity / Slither:** 0.8.24 / 0.11.6 | **Ngày hoàn thành:** 20/11/2026
**URL GitHub repository:** https://github.com/iamduy06/NT547_Lab06_24520376.git

## 1. Static scan (2,0 điểm)

- Lệnh raw: `python tools/scan.py --mode raw --tag before`
- Số lượng finding raw từ `evidence/before_raw/summary.json`:
  - High: 3; Medium: 3; Low: 1; Informational: 5; Optimization: 0 (Tổng cộng: 12 findings)
- Chạy configured: `python tools/scan.py --mode configured --tag before`
- So sánh raw/configured:
  Chế độ configured kích hoạt bộ lọc trong `slither.config.json` (`exclude_low: true`, `exclude_informational: true`, `detectors_to_exclude: "solc-version"`), giúp giảm tổng số cảnh báo từ 12 xuống còn 6 (loại bỏ 1 Low và 5 Informational). Toàn bộ 3 finding High và 3 finding Medium được giữ nguyên đầy đủ, không bị ẩn hay bỏ sót lỗi nguy hiểm.
- 3 detector **khác tên**: `suicidal`, `tx-origin`, `controlled-delegatecall`

| ID finding | Detector | Impact | Confidence | Source (file:dòng) | Luồng dữ liệu: đầu vào -> thao tác -> tác hại |
|---|---|---|---|---|---|
| F01 | `suicidal` | High | High | `AuditTarget.sol:44-46` (hàm `closeVault`) | Caller bất kỳ gọi `closeVault()` -> Không có kiểm tra phân quyền, thực thi trực tiếp `selfdestruct(payable(msg.sender))` -> Hợp đồng bị hủy, toàn bộ số dư ETH chuyển cho kẻ tấn công. |
| F02 | `tx-origin` | Medium | Medium | `AuditTarget.sol:48-52` (dòng 49, hàm `updateOwner`) | Owner bị dụ gọi contract độc hại -> Contract độc hại gọi `updateOwner(hacker)` -> Kiểm tra `tx.origin == owner` thỏa mãn vì Owner là người ký gốc -> Quyền `owner` bị chuyển cho hacker. |
| F03 | `controlled-delegatecall` | High | Medium | `AuditTarget.sol:59-62` (dòng 60, hàm `plugin`) | Caller bất kỳ truyền `target` và `data` tùy ý -> Không có phân quyền, gọi `target.delegatecall(data)` -> Thực thi mã độc trong context storage của hợp đồng, có thể ghi đè biến `owner` và chiếm đoạt contract. |

## 2. Triage và sửa lỗi (2,5 điểm)

Đọc toàn bộ AuditTarget.sol: nhận diện **4 mẫu lỗi thật + 2 đoạn cần đánh giá ngữ cảnh**,
kể cả khi Slither không hiển thị đủ 6 cảnh báo. Với mẫu không có detector,
ghi “Manual review / Not reported”, KHÔNG sửa slither.json hoặc tạo finding giả.

| Detector + vị trí | TP / FP / Chưa kết luận | Bằng chứng kiểm soát/khả năng khai thác | Biện pháp (Fix / Accept có lý do) | Sau sửa |
|---|---|---|---|---|
| | | | | |
| | | | | |
| | | | | |
| | | | | |
| | | | | |
| | | | | |

- Mô tả ít nhất 01 kịch bản khai thác TP: người gọi -> điều kiện -> call/state -> hậu quả: ...
- Phân tích 01 finding có severity cao nhưng risk thực tế không tương ứng: ...
- Dẫn bằng chứng `git diff`, scan before/after và giải thích cảnh báo còn lại: ...
- Lý do của mọi `slither-disable-next-line`: ... (tên detector, đúng vị trí, kiểm soát bù trừ).

## 3. Kiến trúc / Inheritance (1,5 điểm)

- Lệnh printer đã chạy: ...
- Ảnh `evidence/architecture/inheritance.png` (hoặc .dot, nếu Graphviz chưa có): ...
- Access control nằm ở ...; logic số dư nằm ở ...; contract triển khai nằm ở ...
- Giải thích 3–5 câu điểm audit cần bắt đầu: ...

## 4. Red -> Green CI (2,5 điểm)

| Phase | Commit (full/short SHA) | Run URL | Kết quả | Detector khiến RED / lý do GREEN |
|---|---|---|---|---|
| Baseline vulnerable | | | RED | |
| Patched | | | GREEN | |

- So sánh local `--fail-none` (thu thập findings) với CI `fail-on: medium`: ...
- `exclude_low/informational` thay đổi kết quả hiển thị ra sao: ...

## 5. Mutation RED -> GREEN (1,5 điểm)

- Mutation một dòng: `require(msg.sender == owner, "not owner")` -> `require(tx.origin == owner, "not owner")` trong `modifier onlyOwner`.
- Detector kỳ vọng: `tx-origin` (mức Medium); xác nhận của em từ CI: ...

| Phase | Commit SHA | Run URL | Kết quả |
|---|---|---|---|
| Mutation | | | RED |
| Revert mutation | | | GREEN |

- Giải thích sự thay đổi về nguồn định danh/authorization: ...

## 6. Bằng chứng, tự kiểm

- [ ] `AuditTarget.sol`, `lab_identity.json`
- [ ] `evidence/before_raw/` và `evidence/before_configured/`
- [ ] `evidence/after_raw/` và `evidence/after_configured/`
- [ ] `evidence/architecture/`
- [ ] 04 URL Actions run RED/GREEN/RED/GREEN + 04 commit SHA
- [ ] Link repo và ảnh màn hình có terminal / URL / commit SHA; không cắt mất ngữ cảnh
- [ ] Các finding được triage, không chép lại mô tả detector thay cho suy luận
- [ ] Tuyệt đối không có seed phrase, private key, credentials

**Nhận xét cuối cùng (5–7 câu):** ...
