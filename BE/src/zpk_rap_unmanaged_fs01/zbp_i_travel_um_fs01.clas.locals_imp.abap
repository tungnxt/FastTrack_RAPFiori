*"* local helper classes for UNMANAGED implementation

"=====================================================================
" UNMANAGED
"   - Developer viet TAT CA: create/update/delete/read/lock + save.
"   - Handler (interaction) CHI don thay doi vao buffer noi bo (mt_*),
"     TUYET DOI khong ghi DB o day.
"   - Saver.save_modified moi la noi ghi DB that su.
"=====================================================================
CLASS lhc_travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PUBLIC SECTION.
    " buffer dung chung giua handler va saver
    CLASS-DATA mt_create TYPE STANDARD TABLE OF ztravel_um_fs01 WITH EMPTY KEY.
    CLASS-DATA mt_update TYPE STANDARD TABLE OF ztravel_um_fs01 WITH EMPTY KEY.
    CLASS-DATA mt_delete TYPE STANDARD TABLE OF ztravel_um_fs01 WITH EMPTY KEY.

  PRIVATE SECTION.
    METHODS create        FOR MODIFY IMPORTING entities FOR CREATE Travel.
    METHODS update        FOR MODIFY IMPORTING entities FOR UPDATE Travel.
    METHODS delete        FOR MODIFY IMPORTING keys     FOR DELETE Travel.
    METHODS read          FOR READ   IMPORTING keys     FOR READ   Travel RESULT result.
    METHODS lock          FOR LOCK   IMPORTING keys     FOR LOCK   Travel.
ENDCLASS.

CLASS lhc_travel IMPLEMENTATION.

  METHOD create.
    LOOP AT entities INTO DATA(e).
      APPEND VALUE #( travel_id      = e-TravelId
                      agency_id      = e-AgencyId
                      customer_id    = e-CustomerId
                      begin_date     = e-BeginDate
                      end_date       = e-EndDate
                      description    = e-Description
                      total_price    = e-TotalPrice
                      currency_code  = e-CurrencyCode
                      overall_status = e-OverallStatus
                      created_by            = sy-uname
                      created_at            = utclong_current( )
                      last_changed_by       = sy-uname
                      last_changed_at       = utclong_current( )
                      local_last_changed_at = utclong_current( ) ) TO mt_create.
      APPEND VALUE #( %cid = e-%cid TravelId = e-TravelId ) TO mapped-travel.
    ENDLOOP.
  ENDMETHOD.

  METHOD update.
    LOOP AT entities INTO DATA(e).
      APPEND VALUE #( travel_id      = e-TravelId
                      agency_id      = e-AgencyId
                      customer_id    = e-CustomerId
                      begin_date     = e-BeginDate
                      end_date       = e-EndDate
                      description    = e-Description
                      total_price    = e-TotalPrice
                      currency_code  = e-CurrencyCode
                      overall_status = e-OverallStatus
                      last_changed_by       = sy-uname
                      last_changed_at       = utclong_current( )
                      local_last_changed_at = utclong_current( ) ) TO mt_update.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete.
    LOOP AT keys INTO DATA(k).
      APPEND VALUE #( travel_id = k-TravelId ) TO mt_delete.
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
    LOOP AT keys INTO DATA(k).
      SELECT SINGLE * FROM ztravel_um_fs01 WHERE travel_id = @k-TravelId INTO @DATA(ls).
      IF sy-subrc = 0.
        APPEND VALUE #( TravelId      = ls-travel_id
                        AgencyId      = ls-agency_id
                        CustomerId    = ls-customer_id
                        BeginDate     = ls-begin_date
                        EndDate       = ls-end_date
                        Description   = ls-description
                        TotalPrice    = ls-total_price
                        CurrencyCode  = ls-currency_code
                        OverallStatus = ls-overall_status
                        CreatedBy          = ls-created_by
                        CreatedAt          = ls-created_at
                        LastChangedBy      = ls-last_changed_by
                        LastChangedAt      = ls-last_changed_at
                        LocalLastChangedAt = ls-local_last_changed_at ) TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD lock.
    " Trong thuc te: goi ENQUEUE tu 1 lock object.
    " Demo giu don gian de tap trung vao save sequence.
    RETURN.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_travel_um DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save_modified REDEFINITION.
    METHODS cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_travel_um IMPLEMENTATION.
  METHOD save_modified.
    IF lhc_travel=>mt_create IS NOT INITIAL.
      INSERT ztravel_um_fs01 FROM TABLE @lhc_travel=>mt_create.
    ENDIF.
    LOOP AT lhc_travel=>mt_update INTO DATA(u).
      " SET tung field -> KHONG ghi de created_by/created_at
      UPDATE ztravel_um_fs01
        SET agency_id      = @u-agency_id,
            customer_id    = @u-customer_id,
            begin_date     = @u-begin_date,
            end_date       = @u-end_date,
            description    = @u-description,
            t