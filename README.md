# FastTrack RAP + Fiori — Booking Application

Training & reference project cho **SAP RAP** (RESTful ABAP Programming Model, BTP ABAP Environment / ABAP Cloud) kết hợp **SAP Fiori Elements (OData V4)**. Kịch bản xuyên suốt (*Golden Thread*): **Booking → Booking Item**, mở rộng thành **multi-view List Report có Tree Table** và **Object Page cho node cây**.

Từ **Buổi 4**, base BO `Booking` được bổ sung **lớp Behavior** → trở thành **Business Object giao dịch** (Create / Update / Delete + **Draft** + **Action** + **EML**). Phần Tree vẫn giữ **read-only** (analytics/hierarchy).

> Tài liệu này mô tả: cấu trúc thư mục, cấu trúc package, ý nghĩa annotation, **lý thuyết Behavior/RAP runtime (managed & unmanaged)**, và toàn bộ chức năng của App (cả BE lẫn FE).
> Tham chiếu: tài liệu chuẩn SAP (help.sap.com / ui5.sap.com) + bộ tài liệu giảng dạy nội bộ trong `03.FastTrack_RAPFiori/RAP-Buoi3` và `RAP-Buoi4`.

---

## 1. Cấu trúc thư mục repo

```
FastTrack_RAPFiori/
├── .abapgit.xml          # abapGit config (STARTING_FOLDER = /BE/src/)
├── README.md             # tài liệu này
├── BE/                   # ===== BACKEND (RAP / ABAP Cloud) =====
│   └── src/              # toàn bộ ABAP repository objects (abapGit FOLDER_LOGIC = FULL)
│       ├── <main package>            # base model + projection + behavior + MDE + value help + service
│       ├── zpk_rap_tree_fs01/        # sub-package: Tree Table (Buổi 3 add-on)
│       ├── zpk_rap_unmanaged_fs01/   # sub-package: RAP Save Options - managed/unmanaged/additional (Buổi 5)
│       └── zpk_rap_eml_fs01/         # sub-package: EML demo (headless)
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

> **Lưu ý abapGit:** file `.abapgit.xml` **phải nằm ở root** của repo; nó đã được trỏ `STARTING_FOLDER = /BE/src/` để abapGit vẫn map đúng object sau khi chuyển source vào `BE/`. Thư mục `FE/` nằm ngoài starting folder nên abapGit bỏ qua. (Khi link repo trong ADT nhớ để Starting Folder = `/BE/src/`, không để mặc định `/src/`.)

---

## 2. Backend — cấu trúc package & object

BE dùng **abapGit FOLDER_LOGIC = FULL** ⇒ mỗi package ABAP = 1 thư mục con.

### 2.1 Package chính (base Booking model)

| Nhóm | Object | Ý nghĩa |
|---|---|---|
| **Database table** | `ZBOOKING_FS01`, `ZBKITEM_FS01`, `ZCUSTOMER_FS01`, `ZSTATUS_FS01` | Bảng dữ liệu: booking header, item, customer, status |
| **Draft table** | `ZBOOKING_FS01_D`, `ZBKITEM_FS01_D` | Bảng shadow lưu nháp (framework-managed, sinh bằng Ctrl+1) |
| **Domain / Data element** | `ZD_CONFIRM_FS01`, `ZD_PRIORITY_FS01` (domain, fixed values) · `ZE_CONFIRM_FS01`, `ZE_PRIORITY_FS01` (data element) | Giá trị cố định cho Confirm/Priority (nguồn dropdown) |
| **Interface CDS (base)** | `ZI_BOOKING_FS01` (root), `ZI_BKITEM_FS01` (composition child) | Mô hình dữ liệu lõi + association tới customer/status |
| **Value-help CDS** | `ZI_CUSTOMER_FS01`, `ZI_BOOKING_STATUS_VH_FS01`, `ZI_CITY_VH_FS01`, `ZI_CONFIRM_VH_FS01`, `ZI_PRIORITY_VH_FS01` | Nguồn value help (F4) cho các field |
| **Projection CDS** | `ZC_BOOKING_FS01`, `ZC_BKITEM_FS01` | View tiêu thụ (`provider contract transactional_query`) expose cho OData |
| **Behavior Definition** | `ZI_BOOKING_FS01` (base: managed + draft + early numbering), `ZC_BOOKING_FS01` (projection) | Lớp hành vi giao dịch (mục 5) |
| **Behavior Pool** | `ZBP_I_BOOKING_FS01` | Handler: auth (global+instance), early numbering, action |
| **Abstract entity** | `ZA_BOOKING_DISC_FS01` | Tham số cho action `applyDiscount` |
| **Metadata Extension** | `ZC_BOOKING_FS01_T01..T17`, `T19`, `ZC_BKITEM_FS01_T01` | Annotation UI tách theo chủ đề (`_Txx` = 1 topic; `T19` = nút action `#FOR_ACTION`) |
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

### 2.3 Sub-package `zpk_rap_unmanaged_fs01` (Buổi 5 — RAP Save Options)

Package demo **4 lựa chọn save** của RAP trên cùng một BO mẫu `Travel`. Mỗi biến thể là một bộ **table + interface CDS + BDEF + behavior pool** độc lập để so sánh song song.

| Biến thể | Kiểu (BDEF header) | Interface CDS | BDEF / Pool | Persistent table | Draft |
|---|---|---|---|---|---|
| **MG** | `managed` | `ZI_TRAVEL_MG_FS01` | `ZBP_I_TRAVEL_MG_FS01` | `ZTRAVEL_MG_FS01` | ✅ `ZDTRAVEL_MG_FS01` |
| **US** | `managed … with unmanaged save` | `ZI_TRAVEL_US_FS01` | `ZBP_I_TRAVEL_US_FS01` (`save_modified`) | `ZTRAVEL_US_FS01` | ✅ `ZDTRAVEL_US_FS01` |
| **AS** | `managed … with additional save` | `ZI_TRAVEL_AS_FS01` | `ZBP_I_TRAVEL_AS_FS01` (`save_modified`) | `ZTRAVEL_AS_FS01` | ✅ `ZDTRAVEL_AS_FS01` |
| **UM** | `unmanaged` | `ZI_TRAVEL_UM_FS01` | `ZBP_I_TRAVEL_UM_FS01` (CRUD + saver) | `ZTRAVEL_UM_FS01` | ❌ (không draft) |

**Object dùng chung:**

| Object | Loại | Vai trò |
|---|---|---|
| `ZTRAVEL_LOG_FS01` | Database table | Bảng log — biến thể **AS** ghi thêm log trong `save_modified` (bảng chính vẫn do framework tự lưu) |
| `ZSV_TRAVEL_SAVE_FS01` | Service Definition | Service demo 4 BO |
| `ZESV_TRAVEL_UNMANAGED_FS01` | Service Extension | `extend service ZSV_BOOKING` → expose `ZZTravelMG`, `ZZTravelAS`, `ZZTravelUS`, `ZZTravelUM` |

> **Đúc kết 4 kiểu:** `managed` = framework ghi hết · `with unmanaged save` = framework lo interaction, **dev ghi** trong `save_modified` (wrap BAPI/API) · `with additional save` = framework **vẫn tự ghi** bảng chính, `save_modified` chỉ để **làm thêm** (ghi log/bảng phụ) · `unmanaged` = dev tự lo toàn bộ CRUD + saver. Xem lý thuyết ở **mục 5.12**.

### 2.4 Sub-package `zpk_rap_eml_fs01` (EML demo)

| Object | Loại | Vai trò |
|---|---|---|
| `ZCL_BOOKING_EML_DEMO_FS01` | Class (`IF_OO_ADT_CLASSRUN`) | Demo EML headless trên Booking BO: `READ / MODIFY / COMMIT ENTITIES`, xử lý `mapped/failed/reported` (chạy F9) |
| `ZCL_BOOKING_EML_TABLES_FS01` | Class | Demo derived types & EML với internal table |

> Lý thuyết EML: **mục 5.10**.

### 2.5 Data model

```
ZI_BOOKING_FS01 (root)
  ├─ composition [0..*] ZI_BKITEM_FS01        (Booking → Item)
  ├─ association ZI_CUSTOMER_FS01              (customer text + F4)
  └─ association ZI_BOOKING_STATUS_VH_FS01     (status text + F4)

Tree node set (union header+item):
  NodeId (H=BookingId / I=BookingId-ItemId), ParentNodeId, self _Parent → recursive hierarchy
```

### 2.6 OData service (sau publish `ZUI_BOOKING_V4`)

| Entity set | Nguồn | Dùng cho | CRUD? |
|---|---|---|---|
| `BookingSrv` | `ZC_BOOKING_FS01` | List Report (tab List) + Object Page | ✅ (managed + draft) |
| `BookingItemSrv` | `ZC_BKITEM_FS01` | Object Page item | ✅ (update/delete + create qua cha) |
| `ZZBookingTree` | `ZC_BOOKINGNODE_FS01` | Tree Table (nguồn **CDS union**) | ❌ read-only |
| `ZZBookingTreeTF` | `ZC_BOOKNODETF_FS01` | Tree Table (nguồn **Table Function**) + Object Page node | ❌ read-only |
| `ZZNodeChild` | `ZCE_NODECHILD_FS01` | Child Nodes trong Object Page của tree TF | ❌ read-only |

---

## 3. Frontend — Fiori Elements app (`FE/`)

App LROP (List Report Object Page) OData V4, template `sap.fe.templates`.

### 3.1 Chức năng chính

- **List Report Multiple View (Multiple Table Mode)** — 1 trang, 3 tab chuyển bằng icon tab bar:
  1. **List** (`BookingSrv`) — GridTable phẳng, có Create/Edit/Delete + action.
  2. **Tree** (`ZZBookingTree`) — TreeTable từ CDS hierarchy (`hierarchyQualifier: ZH_BOOKINGNODE_FS01`).
  3. **TF Tree** (`ZZBookingTreeTF`) — TreeTable từ table function (`hierarchyQualifier: ZH_BOOKNODETF_FS01`).
- **Filter bar**: value help (Customer/City/Status/Confirm/Priority), default value Priority, required field.
- **Object Page Booking** → sub Object Page **Booking Item** (navigation qua `_bookingItem`), có Draft (Edit/Save/Discard) + nút action **Accept / Cancel / Discount**.
- **Object Page Tree Node** (`ZZBookingTreeTF`): section **Node Details** + section **Child Nodes** (lấy từ custom entity `ZZNodeChild`).
- **Feature hiển thị**: criticality (icon màu cho Status/Priority), Micro Chart (Bullet giá), Rating & Progress indicator, Contact/Quick View (email), text arrangement (ID + text), currency/amount, semantic key (BookingId đậm + neo draft indicator).
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
| `@UI.lineItem` | Cột của bảng (List Report / table trong OP); `position`, `label`, `importance`, `criticality`; `type: #FOR_ACTION` = nút action trên toolbar |
| `@UI.selectionField` | Field xuất hiện trên filter bar |
| `@UI.selectionVariant` | Biến thể lọc — dùng làm `annotationPath` cho từng tab multi-view |
| `@UI.presentationVariant` | Sort mặc định + visualization (LineItem/Chart) |
| `@UI.facet` | Bố cục Object Page: section (Collection / Identification / LineItem / DataPoint reference); `purpose: #HEADER` = tile KPI read-only |
| `@UI.identification` | Field/nút action trong section chi tiết (form) của Object Page |
| `@UI.fieldGroup` | Nhóm field (dùng trong facet FieldGroup) — nơi field trở nên **editable** |
| `@UI.dataPoint` | KPI đơn (Rating, Progress, giá trị + ngưỡng criticality) — hiển thị read-only |
| `@UI.chart` | Định nghĩa micro/analytical chart (vd Bullet) |
| `@UI.hidden` / `@UI.hiddenFilter` | Ẩn field khỏi UI / khỏi filter bar |

> ⚠️ Field chỉ nằm ở `@UI.dataPoint`/header facet là **read-only**; muốn edit/create phải đưa vào `@UI.fieldGroup`/`@UI.identification` của một section.

### 4.2 Semantics / Consumption / Search

| Annotation | Ý nghĩa |
|---|---|
| `@Semantics.amount.currencyCode` | Đánh dấu field tiền + trỏ tới field currency |
| `@Semantics.quantity.unitOfMeasure` | Field số lượng + đơn vị |
| `@Semantics.eMail.address` | Field email (bật Contact/mailto) |
| `@Semantics.systemDateTime.localInstanceLastChangedAt` | Timestamp tự cập nhật — dùng cho `etag` (concurrency) |
| `@Consumption.valueHelpDefinition` | Khai value help (F4); `useForValidation` để check hợp lệ |
| `@ObjectModel.text.element` | Text đi kèm ID (hiển thị tên thay mã) |
| `@ObjectModel.semanticKey` | Key nghiệp vụ (hiển thị đậm + neo draft indicator) |
| `@Search.searchable` / `@Search.defaultSearchElement` | Bật ô tìm kiếm tự do + field được tìm |

### 4.3 RAP / Hierarchy / Metadata

| Annotation | Ý nghĩa |
|---|---|
| `provider contract transactional_query` | View projection cho OData (đủ dùng cho cả transactional lẫn query) |
| `@OData.hierarchy.recursiveHierarchy` | Khai recursive hierarchy (trỏ tới `define hierarchy`) → FE render **TreeTable** |
| `define hierarchy ... as parent child hierarchy` | Định nghĩa cây: source, child-to-parent association, start, siblings order |
| `@ObjectModel.query.implementedBy` | Custom entity: trỏ tới query class (`IF_RAP_QUERY_PROVIDER`) |
| `@Metadata.layer` | Layer của Metadata Extension (#CORE/#CUSTOMER…) |
| `@Metadata.allowExtensions` | Cho phép entity nhận Metadata Extension |
| `@Metadata.ignorePropagatedAnnotations` | Không kế thừa annotation từ view dưới |
| `@AccessControl.authorizationCheck` | Chế độ kiểm tra quyền (DCL) |
| `@AbapCatalog.extensibility.extensible` | Service cho phép mở rộng (`extend service`) |

---

## 5. Behavior / RAP Runtime (Lý thuyết)

> Base BO `Booking` là **managed + draft + early numbering**. Mục này giải thích runtime RAP và toàn bộ keyword của BDEF, kèm phần **Unmanaged / Managed + Unmanaged Save** (chi tiết ở 5.12).

### 5.1 Runtime RAP — 2 pha

```
User → [INTERACTION PHASE: transactional buffer]  → SAVE/COMMIT →  [SAVE PHASE: DB]
        numbering · feature control · determination                managed: framework tự ghi
        · validation · action  (CHƯA vào DB)                       unmanaged: dev tự ghi (save_modified)
```

- **Interaction phase**: mọi thay đổi nằm trong *transactional buffer* (chưa xuống DB).
- **Save phase**: đẩy buffer xuống DB.
- ⚠️ **Quy tắc vàng**: KHÔNG gọi `COMMIT ENTITIES` / BAPI / Released API ở interaction phase → runtime dump `BEHAVIOR_ILLEGAL_STATEMENT`.

### 5.2 Ba kiểu implementation

| Kiểu | Khai BDEF | Ai ghi DB | Dùng cho |
|---|---|---|---|
| **Managed** | `managed implementation in class …` | Framework tự INSERT/UPDATE/DELETE | Bảng Z thuần (case Booking) |
| **Managed + Unmanaged Save** | `managed … with unmanaged save` | Framework (interaction) + `save_modified` (ghi) | Wrap BAPI / Released API |
| **Unmanaged** | `unmanaged implementation in class …` | Dev tự lo toàn bộ CRUD + saver | Có sẵn persistence/BAPI/FM legacy |

→ Chi tiết Unmanaged & Managed+Unmanaged Save: **mục 5.12**.

### 5.3 Giải phẫu BDEF header (keyword)

| Keyword | Ý nghĩa | Biến thể |
|---|---|---|
| `managed implementation in class … unique` | Framework lo CRUD; 1 pool class | `unmanaged …` · `… with unmanaged save` |
| `strict ( 2 )` | Mức kiểm cú pháp mới nhất (bắt buộc BTP/Cloud); cần cho extensibility & release API | `strict ( 1 )` (cũ) |
| `with draft` | Bật draft cho cả BO | `with collaborative draft` |
| `persistent table` | Bảng đích managed tự ghi | (unmanaged: không có → dev tự ghi) |
| `draft table` | Bảng shadow lưu nháp (ADT sinh bằng Ctrl+1) | — |
| `lock master` | **Pessimistic lock** ở root | `lock dependent by _assoc` (child) |
| `total etag` | Etag cấp cả cụm draft (root + con) | — |
| `authorization master ( global, instance )` | Chủ phân quyền: global (theo thao tác) + instance (theo record) | `( global )` · `( instance )` · `dependent by _assoc` |
| `etag master <field>` | **Optimistic lock** field mốc thời gian | `etag dependent by _assoc` |
| `early numbering` | Cấp key ở interaction phase (`earlynumbering_create`) | managed UUID · external · `late numbering` |
| `mapping for <table>` | Map CDS element ↔ cột DB (bỏ calculated field) | — |

### 5.4 Field control · Operations · Association

| Khai | Ý nghĩa |
|---|---|
| `field ( readonly )` | Chỉ đọc (key hệ cấp, admin field) |
| `field ( readonly : update )` | Ghi lúc create, khoá lúc update |
| `field ( mandatory )` / `( mandatory : create )` | Bắt buộc nhập (mọi lúc / chỉ create) |
| `field ( features : instance )` | **Động** — readonly/mandatory/hidden theo record (`get_instance_features`) |
| `field ( numbering : managed )` | Key auto UUID |
| `field ( suppress )` | Ẩn field khỏi BO/OData |
| `create; update; delete;` | Thao tác CRUD |
| `association _child { create; with draft; }` | Cho tạo con lồng trong cha (deep create) + draft |

### 5.5 Concurrency: Lock vs ETag

| | **Lock (pessimistic)** | **ETag (optimistic)** |
|---|---|---|
| Từ khoá | `lock master` / `dependent by` | `etag master` / `total etag` |
| Cơ chế | Giành trước: ai Edit trước giữ khoá | Kiểm lúc ghi: ghi sau bị chặn nếu dữ liệu đã đổi (→ 412) |
| Áp dụng | Draft UI (exclusive lock) | Ghi trực tiếp OData/EML (`If-Match`) |

### 5.6 Numbering (4 chiến lược)

| Chiến lược | Keyword | Cấp key ở đâu | Hợp với |
|---|---|---|---|
| Managed (UUID) | `field ( numbering : managed )` | Framework sinh UUID | Key `sysuuid_x16` |
| **Early internal** | `early numbering` | `earlynumbering_create` | **Semantic key** (BookingId char) |
| Early external | `early numbering` | User nhập | ID do user đặt |
| Late | `late numbering` | `adjust_numbers` (saver, save phase) | Key phụ thuộc hệ ngoài |

> ⚠️ Handler `earlynumbering_create` **phải trả `mapped` cho MỌI instance** (kể cả lúc Activate draft key đã có → echo lại), nếu không dump `CX_CSP_ACT_RESPONSE`.

### 5.7 Behavior Pool & Behavior Projection

- **Behavior Pool** (`ZBP_I_BOOKING_FS01`): class chứa handler (auth, numbering, action…), viết ở tab **Local Types (CCIMP)**.
- **Behavior Projection** (`define behavior for ZC_BOOKING_FS01`): từ năng lực BDEF gốc, **chọn cái nào lộ ra UI/OData** (`use create/update/delete`, `use action …`, `use draft`).

### 5.8 Draft

- 4 draft action **bắt buộc** khi `strict(2)` + draft: `Edit`, `Activate optimized`, `Discard`, `Resume`.
- `draft determine action Prepare { }`: nơi chạy **validation trước khi Activate** (dùng với `Activate optimized`).
- Vòng đời: Active ⇄ Draft (Edit/Create/Resume/Discard/Activate).

### 5.9 Determination · Validation · Action

| Loại | Khai BDEF | Handler | Trạng thái trong project |
|---|---|---|---|
| **Determination** | `determination … on modify/save` | `FOR DETERMINE ON …` | Roadmap (setInitialStatus, calcTotalPrice) |
| **Validation** | `validation … on save` | `FOR VALIDATE ON SAVE` | Roadmap (validateCustomer, validateDates) → đưa vào `Prepare` |
| **Action** | `action … result [1] $self` | `FOR MODIFY … FOR ACTION` | ✅ `acceptBooking`, `cancelBooking`, `applyDiscount(param)` |

### 5.10 EML (Entity Manipulation Language)

"SQL cho RAP BO" — thao tác qua Business Object (giữ nguyên lock/validation/determination/numbering).

| Lệnh | Việc | Pha |
|---|---|---|
| `READ ENTITIES OF …` | Đọc từ BO | Interaction |
| `MODIFY ENTITIES OF …` | Create/Update/Delete vào buffer | Interaction |
| `COMMIT ENTITIES …` | Đẩy buffer xuống DB | Save (chỉ ngoài BO) |

- Trong handler behavior: dùng `MODIFY/READ ENTITIES … IN LOCAL MODE` và **KHÔNG** `COMMIT` (framework lo).
- Derived types: `%cid` (content id create), `%cid_ref` (nối con↔cha), `%tky` (= key + draft flag), `%param` (tham số action), `%is_draft`.

### 5.11 Object Behavior trong package

| Object | Loại | Vai trò |
|---|---|---|
| `ZI_BOOKING_FS01` / `ZI_BKITEM_FS01` | BDEF base | Managed + draft + early numbering; lock/auth/etag |
| `ZBP_I_BOOKING_FS01` | Behavior Pool | `get_global_authorizations`, `get_instance_authorizations`, `earlynumbering_create`, action handlers |
| `ZC_BOOKING_FS01` / `ZC_BKITEM_FS01` | BDEF projection | `use …` + `use draft` + `use action` |
| `ZBOOKING_FS01_D` / `ZBKITEM_FS01_D` | Draft table | Lưu nháp (framework-managed) |
| `ZA_BOOKING_DISC_FS01` | Abstract entity | Tham số cho action `applyDiscount` |
| `ZC_BOOKING_FS01_T19` | Metadata Extension | `#FOR_ACTION` — nút Accept/Cancel/Discount trên UI |

### 5.12 Unmanaged & Managed + Unmanaged Save (chi tiết)

Khi **KHÔNG** để framework tự ghi DB (đã có persistence/BAPI/FM legacy, hoặc cần logic ghi đặc thù), có 2 mức:

**A. Managed + Unmanaged Save** — giữ managed cho interaction (numbering, determination, validation, draft…), **chỉ override bước ghi**. Đây là cách phổ biến để **wrap BAPI / Released API**.

```abap
managed implementation in class zbp_i_booking_fs01 unique;
strict ( 2 );
with draft;

define behavior for ZI_BOOKING_FS01 alias Booking
persistent table zbooking_fs01
lock master
authorization master ( global )
with unmanaged save              "<== chỉ khác managed ở đây
{ ... create; update; delete; ... }
```

```abap
" Saver class (Local Types): chỉ redefine save_modified
CLASS lsc_booking DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save_modified REDEFINITION.
ENDCLASS.

METHOD save_modified.
  " create/update/delete là các bảng buffer do framework gom sẵn.
  IF create-booking IS NOT INITIAL.
    LOOP AT create-booking INTO DATA(ls).
      " Gọi BAPI / Released API Ở ĐÂY (save phase) — hợp lệ.
      " CALL FUNCTION 'BAPI_...' / MODIFY ENTITIES OF I_...TP ...
    ENDLOOP.
  ENDIF.
  " tương tự cho update-booking / delete-booking
ENDMETHOD.
```

> ⚠️ **BAPI / Released API / COMMIT chỉ được gọi trong `save_modified` (save phase)** — không bao giờ ở determination/validation/action (interaction). Vi phạm → `BEHAVIOR_ILLEGAL_STATEMENT`.

**B. Unmanaged thuần** — dev tự lo **toàn bộ** CRUD + saver (không có `persistent table` auto).

```abap
unmanaged implementation in class zbp_i_booking_fs01_um unique;
strict ( 2 );

define behavior for ZI_BOOKING_FS01 alias Booking
lock master
early numbering
{ create; update; delete; ... }
```

```abap
" Interaction phase: gom thay đổi vào buffer nội bộ (CHƯA chạm DB)
METHODS create FOR MODIFY IMPORTING entities FOR CREATE Booking.
METHODS update FOR MODIFY IMPORTING entities FOR UPDATE Booking.
METHODS delete FOR MODIFY IMPORTING keys     FOR DELETE Booking.
METHODS read   FOR READ   IMPORTING keys     FOR READ  Booking RESULT result.

" Save phase: dev TỰ đẩy buffer xuống DB
CLASS lsc_booking DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save_modified REDEFINITION.   " tự INSERT/UPDATE/DELETE hoặc gọi BAPI
ENDCLASS.
```

**Saver class — các method có thể redefine:**

| Method | Chạy khi | Dùng để |
|---|---|---|
| `finalize` | Đầu save sequence | Chốt/điều chỉnh buffer trước khi lưu |
| `check_before_save` | Trước khi ghi | Kiểm tra cuối; fail → huỷ toàn bộ save |
| `adjust_numbers` | Save phase (late numbering) | Cấp key cuối (`%pid` → key thật) |
| `save_modified` | Ghi | INSERT/UPDATE/DELETE hoặc gọi BAPI/Released API |
| `cleanup_finalize` | Cuối | Dọn tài nguyên tạm |

**So sánh nhanh:**

| | Managed | Managed + Unmanaged Save | Unmanaged |
|---|---|---|---|
| Ghi DB | Framework | `save_modified` | `save_modified` (dev) |
| CRUD interaction | Framework | Framework | Dev tự viết handler |
| Draft | Sẵn (`with draft`) | Sẵn | Tự lo (phức tạp) |
| Hợp với | Bảng Z thuần (Booking) | Wrap BAPI/API | Legacy có sẵn persistence |

> 🔬 **Demo thực tế 4 kiểu save** nằm ở package `zpk_rap_unmanaged_fs01` (mục 2.3): 4 biến thể Travel `MG / US / AS / UM` để so sánh song song trên Preview.

---

## 6. Ba cách dựng Tree Table (bài học kiến trúc)

| Nguồn | Tree thật? | Logic tự viết | Ghi chú |
|---|---|---|---|
| **CDS view (union)** — `ZC_BOOKINGNODE_FS01` | ✅ | Arithmetic/case/aggregate (SQL) | Đơn giản nhất, chạy mọi môi trường |
| **CDS Table Function** — `ZC_BOOKNODETF_FS01` | ✅ | **SQLScript thủ tục** (join/VAT/roll-up) | Cần AMDP (on-prem / Private Edition / Embedded Steampunk) |
| **Custom Entity** — `ZCE_NODECHILD_FS01` | ❌ (chỉ flat/list) | ABAP tự do | Hierarchy engine chạy SQL, không đọc được ABAP runtime → không tree; hợp cho list con trong Object Page hoặc nguồn remote |

> Điểm mấu chốt để tree hoạt động: entity **được expose** phải có (1) `@OData.hierarchy.recursiveHierarchy`, (2) expose **self-association `_Parent`**; manifest tab tree cần `tableSettings.type = "TreeTable"` + `hierarchyQualifier = <tên define hierarchy>` (đọc từ `$metadata`, term `Aggregation/Hierarchy.RecursiveHierarchy`).

---

## 7. Cách chạy

**Backend:** import repo (BE/) bằng abapGit vào ABAP Cloud/on-stack → activate → publish service binding `ZUI_BOOKING_V4`. Chạy `ZCL_BOOKING_DATA_GEN` để sinh dữ liệu mẫu.

**Thứ tự activate behavior (khi build):** DB table → draft table → BDEF base (Ctrl+F3) → Behavior Pool → BDEF projection → Abstract entity → Metadata Extension → Service Def/Binding.

**Frontend:** trong `FE/` chạy `npm install` rồi `npm start` (UI5 tooling), hoặc deploy lên ABAP repository. App trỏ service `/sap/opu/odata4/sap/zui_booking_v4/srvd/sap/zsv_booking/0001/`.

---

## 8. App Preview
**Scope của Package Lớn**

<img width="1920" height="911" alt="image" src="https://github.com/user-attachments/assets/2a64edf4-3c68-44c6-8d3a-64991016b22e" />

<img width="1920" height="911" alt="image" src="https://github.com/user-attachments/assets/5268541f-8c4c-450f-82fd-263d31616410" />

<img width="1920" height="911" alt="image" src="https://github.com/user-attachments/assets/e8a3e115-5009-47a1-a8c8-890d71c8f92d" />

<img width="1920" height="911" alt="image" src="https://github.com/user-attachments/assets/43ea0df7-d113-4677-b5ae-a60086d25743" />

<img width="1920" height="911" alt="image" src="https://github.com/user-attachments/assets/4480e007-dfd9-4f4a-ae65-8e50f050f9fb" />

<img width="1920" height="911" alt="image" src="https://github.com/user-attachments/assets/dce195a6-3e4e-4d68-b2ec-69cabbe03cfb" />


**Scope của Package ZPK_RAP_TREE_FS01**

<img width="1920" height="911" alt="image" src="https://github.com/user-attachments/assets/aa41344d-de97-4fa7-94c6-7ad50c9c24ec" />

<img width="1920" height="911" alt="image" src="https://github.com/user-attachments/assets/f6a75eec-8d63-4e1e-ba20-68d6583dc10d" />

<img width="1920" height="911" alt="image" src="https://github.com/user-attachments/assets/320568de-bb32-42ae-b6c3-0dcee5310565" />

<img width="1920" height="911" alt="image" src="https://github.com/user-attachments/assets/d5be75d5-1f52-4729-8464-18a8ec5e9eba" />


---
## 9. Tài liệu tham khảo

**SAP chính thức**
- Fiori Elements OData V4: <https://ui5.sap.com/#/topic/03265b0408e2432c9571d6b3feb6b1fd>
- List Report: <https://ui5.sap.com/#/topic/1cf5c7f5b81c4cb3ba98fd14314d4504>
- Multiple Views (Multiple Table Mode): <https://ui5.sap.com/#/topic/37aeed74e17a42caa2cba3123f0c15fc>
- Multiple Views – different entity sets: <https://ui5.sap.com/#/topic/b6b59e4a4c3548cf83ff9c3b955d3ba3>
- Tree Tables: <https://ui5.sap.com/#/topic/7cf7a31fd1ee490ab816ecd941bd2f1f>
- CDS Hierarchies: <https://help.sap.com/docs/abap-cloud/abap-data-models/cds-hierarchies>
- Implementing Treeviews (RAP): <https://help.sap.com/docs/abap-cloud/abap-rap/implementing-hierarchical-view>
- Develop RAP BO (managed/unmanaged): <https://help.sap.com/docs/abap-cloud/abap-rap/developing-transactional-apps-with-rap>
- Unmanaged / save_modified: <https://help.sap.com/docs/abap-cloud/abap-rap/unmanaged-implementation-type>
- Custom Entity / Query Provider: <https://developers.sap.com/tutorials/abap-environment-a4c-create-custom-entity.html>
- Fiori Feature Showcase (RAP + FE): <https://github.com/SAP-samples/abap-platform-fiori-feature-showcase>
