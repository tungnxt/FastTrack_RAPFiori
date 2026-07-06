# FastTrack RAP + Fiori — Booking Application

Training & reference project cho **SAP RAP** (RESTful ABAP Programming Model, BTP ABAP Environment / ABAP Cloud) kết hợp **SAP Fiori Elements (OData V4)**. Kịch bản xuyên suốt (*Golden Thread*): **Booking → Booking Item**, mở rộng thành **multi-view List Report có Tree Table** và **Object Page cho node cây**.

> Tài liệu này mô tả: cấu trúc thư mục, cấu trúc package, ý nghĩa annotation, và toàn bộ chức năng của App (cả BE lẫn FE).
> Tham chiếu: tài liệu chuẩn SAP (help.sap.com / ui5.sap.com) + bộ tài liệu giảng dạy nội bộ trong `03.FastTrack_RAPFiori/RAP-Buoi3`.

---

## 1. Cấu trúc thư mục repo

```
FastTrack_RAPFiori/
├── .abapgit.xml          # abapGit config (STARTING_FOLDER = /BE/src/)
├── README.md             # tài liệu này
├── BE/                   # ===== BACKEND (RAP / ABAP Cloud) =====
│   └── src/              # toàn bộ ABAP repository objects (abapGit FOLDER_LOGIC = FULL)
│       ├── <main package>            # base model + projection + MDE + value help + service
│       └── zpk_rap_tree_fs01/        # sub-package: toàn bộ phần Tree Table (Buổi 3 add-on)
└── FE/                   # ===== FRONTEND (Fiori Elements, SAPUI5) =====
    ├── package.json, ui5.yaml, ...   # UI5 tooling
    └── webapp/
        ├── manifest.json             # cấu hình app: List Report multi-view + Object Pages
        ├── Component.js
        ├── annotations/annotation.xml
        ├── localService/mainService/metadata.xml
        ├── i18n/i18n.properties
        └── test/integration/         # OPA5 journeys
```

> **Lưu ý abapGit:** file `.abapgit.xml` **phải nằm ở root** của repo; nó đã được trỏ `STARTING_FOLDER = /BE/src/` để abapGit vẫn map đúng object sau khi chuyển source vào `BE/`. Thư mục `FE/` nằm ngoài starting folder nên abapGit bỏ qua.

---

## 2. Backend — cấu trúc package & object

BE dùng **abapGit FOLDER_LOGIC = FULL** ⇒ mỗi package ABAP = 1 thư mục con.

### 2.1 Package chính (base Booking model)

| Nhóm | Object | Ý nghĩa |
|---|---|---|
| **Database table** | `ZBOOKING_FS01`, `ZBKITEM_FS01`, `ZCUSTOMER_FS01`, `ZSTATUS_FS01` | Bảng dữ liệu: booking header, item, customer, status |
| **Domain / Data element** | `ZD_CONFIRM_FS01`, `ZD_PRIORITY_FS01` (domain, fixed values) · `ZE_CONFIRM_FS01`, `ZE_PRIORITY_FS01` (data element) | Giá trị cố định cho Confirm/Priority (nguồn dropdown) |
| **Interface CDS (base)** | `ZI_BOOKING_FS01` (root), `ZI_BKITEM_FS01` (composition child) | Mô hình dữ liệu lõi + association tới customer/status |
| **Value-help CDS** | `ZI_CUSTOMER_FS01`, `ZI_BOOKING_STATUS_VH_FS01`, `ZI_CITY_VH_FS01`, `ZI_CONFIRM_VH_FS01`, `ZI_PRIORITY_VH_FS01` | Nguồn value help (F4) cho các field |
| **Projection CDS** | `ZC_BOOKING_FS01`, `ZC_BKITEM_FS01` | View tiêu thụ (`provider contract transactional_query`) expose cho OData |
| **Metadata Extension** | `ZC_BOOKING_FS01_T01..T17`, `ZC_BKITEM_FS01_T01` | Annotation UI tách theo chủ đề (mỗi `_Txx` = 1 topic: lineItem, facet, value help, criticality, chart…) |
| **Service Definition** | `ZSV_BOOKING` (extensible) | `expose BookingSrv, BookingItemSrv` |
| **Service Binding** | `ZUI_BOOKING_V4` | OData **V4 – UI**, publish endpoint |
| **Helper class** | `ZCL_BOOKING_DATA_GEN` | Sinh dữ liệu mẫu |

### 2.2 Sub-package `zpk_rap_tree_fs01` (Tree Table add-on — Buổi 3)

Toàn bộ phần cây tách riêng để không đụng base model.

| Object | Loại | Vai trò |
|---|---|---|
| `ZI_BOOKINGNODE_BASE_FS01` | CDS view (union) | Gộp header + item thành **node phẳng** (NodeId/ParentNodeId), tính VAT/roll-up bằng SQL |
| `ZI_BOOKINGNODE_FS01` | CDS view | Thêm **self-association `_Parent`** + annotation `@OData.hierarchy.recursiveHierarchy` |
| `ZH_BOOKINGNODE_FS01` | `define hierarchy` | Định nghĩa parent-child hierarchy (nguồn CDS union) |
| `ZC_BOOKINGNODE_FS01` (+ `.ddlx`) | Projection + MDE | Expose tree; UI lineItem; qualifier hierarchy = `ZH_BOOKINGNODE_FS01` |
| `ZTF_BOOKINGNODE_FS01` | **CDS Table Function** | Nguồn node bằng SQLScript (join + VAT + roll-up + child count) |
| `ZCL_BOOKINGNODE_TF` | AMDP class | Cài đặt table function (`FOR TABLE FUNCTION`, LANGUAGE SQLSCRIPT) |
| `ZI_BOOKNODETF_FS01` | CDS view | View trên table function + `_Parent` (self) + `_Children` (tới custom entity) + recursiveHierarchy |
| `ZH_BOOKNODETF_FS01` | `define hierarchy` | Hierarchy cho nhánh table function |
| `ZC_BOOKNODETF_FS01` | Projection | Expose tree (table function); facet Object Page (Node Details + Child Nodes) |
| `ZCE_NODECHILD_FS01` | **Custom Entity** | Node con hiển thị trong Object Page (query provider tự viết) |
| `ZCL_NODECHILD_QUERY` | Query class | `IF_RAP_QUERY_PROVIDER` — lọc theo `ParentNodeId`, đọc lại table function |
| `ZC_BOOKING_FS01_T18` | MDE | `@UI.selectionVariant` cho tab List (multi-view) |
| `ZESV_BOOKING_TREE` | **Service Extension** | `extend service ZSV_BOOKING` → expose `ZZBookingTree`, `ZZBookingTreeTF`, `ZZNodeChild` |

### 2.3 Data model

```
ZI_BOOKING_FS01 (root)
  ├─ composition [0..*] ZI_BKITEM_FS01        (Booking → Item)
  ├─ association ZI_CUSTOMER_FS01              (customer text + F4)
  └─ association ZI_BOOKING_STATUS_VH_FS01     (status text + F4)

Tree node set (union header+item):
  NodeId (H=BookingId / I=BookingId-ItemId), ParentNodeId, self _Parent → recursive hierarchy
```

### 2.4 OData service (sau publish `ZUI_BOOKING_V4`)

| Entity set | Nguồn | Dùng cho |
|---|---|---|
| `BookingSrv` | `ZC_BOOKING_FS01` | List Report (tab List) + Object Page |
| `BookingItemSrv` | `ZC_BKITEM_FS01` | Object Page item |
| `ZZBookingTree` | `ZC_BOOKINGNODE_FS01` | Tree Table (nguồn **CDS union**) |
| `ZZBookingTreeTF` | `ZC_BOOKNODETF_FS01` | Tree Table (nguồn **Table Function**) + Object Page node |
| `ZZNodeChild` | `ZCE_NODECHILD_FS01` | Child Nodes trong Object Page của tree TF |

---

## 3. Frontend — Fiori Elements app (`FE/`)

App LROP (List Report Object Page) OData V4, template `sap.fe.templates`.

### 3.1 Chức năng chính

- **List Report Multiple View (Multiple Table Mode)** — 1 trang, 3 tab chuyển bằng icon tab bar:
  1. **List** (`BookingSrv`) — GridTable phẳng.
  2. **Tree** (`ZZBookingTree`) — TreeTable từ CDS hierarchy (`hierarchyQualifier: ZH_BOOKINGNODE_FS01`).
  3. **TF Tree** (`ZZBookingTreeTF`) — TreeTable từ table function (`hierarchyQualifier: ZH_BOOKNODETF_FS01`).
- **Filter bar**: value help (Customer/City/Status/Confirm/Priority), default value Priority, required field.
- **Object Page Booking** → sub Object Page **Booking Item** (navigation qua `_bookingItem`).
- **Object Page Tree Node** (`ZZBookingTreeTF`): section **Node Details** + section **Child Nodes** (lấy từ custom entity `ZZNodeChild`).
- **Feature hiển thị**: criticality (icon màu cho Status/Priority), Micro Chart (Bullet giá), Rating & Progress indicator, Contact/Quick View (email), text arrangement (ID + text), currency/amount, semantic key (BookingId đậm).
- **Tính toán**: `AmountInclVat` (VAT 10%), `Amount` roll-up từ item, `ChildCount` — thực hiện ở CDS/SQLScript (không phải UI).

### 3.2 File quan trọng

| File | Nội dung |
|---|---|
| `webapp/manifest.json` | routing (List + 4 Object Page targets), `views.paths` (3 tab), `controlConfiguration` (GridTable/TreeTable + hierarchyQualifier) |
| `webapp/annotations/annotation.xml` | annotation UI cục bộ (nếu có) |
| `webapp/localService/mainService/metadata.xml` | metadata mock/local |
| `webapp/test/integration/*.js` | OPA5 journey test |

---

## 4. Ý nghĩa Annotation (tra cứu nhanh)

### 4.1 UI annotation (dựng màn hình Fiori Elements)

| Annotation | Ý nghĩa |
|---|---|
| `@UI.headerInfo` | Tiêu đề đối tượng (TypeName/Title/Description) trên Object Page & tab |
| `@UI.lineItem` | Cột của bảng (List Report / table trong OP); `position`, `label`, `importance`, `criticality` |
| `@UI.selectionField` | Field xuất hiện trên filter bar |
| `@UI.selectionVariant` | Biến thể lọc — dùng làm `annotationPath` cho từng tab multi-view |
| `@UI.presentationVariant` | Sort mặc định + visualization (LineItem/Chart) |
| `@UI.facet` | Bố cục Object Page: section (Collection / Identification / LineItem reference) |
| `@UI.identification` | Field trong section chi tiết (form) của Object Page |
| `@UI.fieldGroup` | Nhóm field (dùng trong facet FieldGroup) |
| `@UI.dataPoint` | KPI đơn (Rating, Progress, giá trị + ngưỡng criticality) |
| `@UI.chart` | Định nghĩa micro/analytical chart (vd Bullet) |
| `@UI.hidden` / `@UI.hiddenFilter` | Ẩn field khỏi UI / khỏi filter bar |

### 4.2 Semantics / Consumption / Search

| Annotation | Ý nghĩa |
|---|---|
| `@Semantics.amount.currencyCode` | Đánh dấu field tiền + trỏ tới field currency |
| `@Semantics.quantity.unitOfMeasure` | Field số lượng + đơn vị |
| `@Semantics.eMail.address` | Field email (bật Contact/mailto) |
| `@Consumption.valueHelpDefinition` | Khai value help (F4); `useForValidation` để check hợp lệ |
| `@ObjectModel.text.element` | Text đi kèm ID (hiển thị tên thay mã) |
| `@ObjectModel.semanticKey` | Key nghiệp vụ (hiển thị đậm + neo draft indicator) |
| `@Search.searchable` / `@Search.defaultSearchElement` | Bật ô tìm kiếm tự do + field được tìm |

### 4.3 RAP / Hierarchy / Metadata

| Annotation | Ý nghĩa |
|---|---|
| `provider contract transactional_query` | View projection read/query cho OData |
| `@OData.hierarchy.recursiveHierarchy` | Khai recursive hierarchy (trỏ tới `define hierarchy`) → FE render **TreeTable** |
| `define hierarchy ... as parent child hierarchy` | Định nghĩa cây: source, child-to-parent association, start, siblings order |
| `@ObjectModel.query.implementedBy` | Custom entity: trỏ tới query class (`IF_RAP_QUERY_PROVIDER`) |
| `@Metadata.layer` | Layer của Metadata Extension (#CORE/#CUSTOMER…) |
| `@Metadata.allowExtensions` | Cho phép entity nhận Metadata Extension |
| `@Metadata.ignorePropagatedAnnotations` | Không kế thừa annotation từ view dưới |
| `@AccessControl.authorizationCheck` | Chế độ kiểm tra quyền (DCL) |
| `@AbapCatalog.extensibility.extensible` | Service cho phép mở rộng (`extend service`) |

---

## 5. Ba cách dựng Tree Table (bài học kiến trúc)

| Nguồn | Tree thật? | Logic tự viết | Ghi chú |
|---|---|---|---|
| **CDS view (union)** — `ZC_BOOKINGNODE_FS01` | ✅ | Arithmetic/case/aggregate (SQL) | Đơn giản nhất, chạy mọi môi trường |
| **CDS Table Function** — `ZC_BOOKNODETF_FS01` | ✅ | **SQLScript thủ tục** (join/VAT/roll-up) | Cần AMDP (on-prem / Private Edition / Embedded Steampunk) |
| **Custom Entity** — `ZCE_NODECHILD_FS01` | ❌ (chỉ flat/list) | ABAP tự do | Hierarchy engine chạy SQL, không đọc được ABAP runtime → không tree; hợp cho list con trong Object Page hoặc nguồn remote |

> Điểm mấu chốt để tree hoạt động: entity **được expose** phải có (1) `@OData.hierarchy.recursiveHierarchy`, (2) expose **self-association `_Parent`**; manifest tab tree cần `tableSettings.type = "TreeTable"` + `hierarchyQualifier = <tên define hierarchy>` (đọc từ `$metadata`, term `Aggregation/Hierarchy.RecursiveHierarchy`).

---

## 6. Cách chạy

**Backend:** import repo (BE/) bằng abapGit vào ABAP Cloud/on-stack → activate → publish service binding `ZUI_BOOKING_V4`. Chạy `ZCL_BOOKING_DATA_GEN` để sinh dữ liệu mẫu.

**Frontend:** trong `FE/` chạy `npm install` rồi `npm start` (UI5 tooling), hoặc deploy lên ABAP repository. App trỏ service `/sap/opu/odata4/sap/zui_booking_v4/srvd/sap/zsv_booking/0001/`.

---
## 7. App Preview


---
## 8. Tài liệu tham khảo

**SAP chính thức**
- Fiori Elements OData V4: <https://ui5.sap.com/#/topic/03265b0408e2432c9571d6b3feb6b1fd>
- List Report: <https://ui5.sap.com/#/topic/1cf5c7f5b81c4cb3ba98fd14314d4504>
- Multiple Views (Multiple Table Mode): <https://ui5.sap.com/#/topic/37aeed74e17a42caa2cba3123f0c15fc>
- Multiple Views – different entity sets: <https://ui5.sap.com/#/topic/b6b59e4a4c3548cf83ff9c3b955d3ba3>
- Tree Tables: <https://ui5.sap.com/#/topic/7cf7a31fd1ee490ab816ecd941bd2f1f>
- CDS Hierarchies: <https://help.sap.com/docs/abap-cloud/abap-data-models/cds-hierarchies>
- Implementing Treeviews (RAP): <https://help.sap.com/docs/abap-cloud/abap-rap/implementing-hierarchical-view>
- Custom Entity / Query Provider: <https://developers.sap.com/tutorials/abap-environment-a4c-create-custom-entity.html>
- Fiori Feature Showcase (RAP + FE): <https://github.com/SAP-samples/abap-platform-fiori-feature-showcase>
