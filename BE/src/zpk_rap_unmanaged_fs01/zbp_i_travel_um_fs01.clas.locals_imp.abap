CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PUBLIC SECTION.
    " buffer dung chung giua handler (interaction) va saver (save)
    CLASS-DATA mt_create TYPE STANDARD TABLE OF ztravel_um_fs01 WITH EMPTY KEY.
    CLASS-DATA mt_update TYPE STANDARD TABLE OF ztravel_um_fs01 WITH EMPTY KEY.
    CLASS-DATA mt_delete TYPE STANDARD TABLE OF ztravel_um_fs01 WITH EMPTY KEY.

  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Travel RESULT result.
    METHODS create FOR MODIFY IMPORTING entities FOR CREATE Travel.
    METHODS update FOR MODIFY IMPORTING entities FOR UPDATE Travel.
    METHODS delete FOR MODIFY IMPORTING keys     FOR DELETE Travel.
    METHODS read   FOR READ   IMPORTING keys     FOR READ   Travel RESULT result.
    METHODS lock   FOR LOCK   IMPORTING keys     FOR LOCK   Travel.
ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD create..
    GET TIME STAMP FIELD DATA(lv_now).
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
                      created_at            = lv_now
                      last_changed_by       = sy-uname
                      last_changed_at       = lv_now
                      local_last_changed_at = lv_now ) TO mt_create.
      APPEND VALUE #( %cid = e-%cid TravelId = e-TravelId ) TO mapped-travel.
    ENDLOOP.
  ENDMETHOD.

  METHOD update.
    GET TIME STAMP FIELD DATA(lv_now).
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
                      last_changed_at       = lv_now
                      local_last_changed_at = lv_now ) TO mt_update.
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
    RETURN.
  ENDMETHOD.
ENDCLASS.

CLASS lsc_ZI_TRAVEL_UM_FS01 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS finalize          REDEFINITION.
    METHODS check_before_save REDEFINITION.
    METHODS save              REDEFINITION.   " <-- unmanaged ghi DB o day
    METHODS cleanup           REDEFINITION.
    METHODS cleanup_finalize  REDEFINITION.
ENDCLASS.

CLASS lsc_ZI_TRAVEL_UM_FS01 IMPLEMENTATION.
  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
    IF lhc_Travel=>mt_create IS NOT INITIAL.
      INSERT ztravel_um_fs01 FROM TABLE @lhc_Travel=>mt_create.
    ENDIF.
    LOOP AT lhc_Travel=>mt_update INTO DATA(u).
      UPDATE ztravel_um_fs01
        SET agency_id      = @u-agency_id,
            customer_id    = @u-customer_id,
            begin_date     = @u-begin_date,
            end_date       = @u-end_date,
            description    = @u-description,
            total_price    = @u-total_price,
            currency_code  = @u-currency_code,
            overall_status = @u-overall_status,
            last_changed_by       = @u-last_changed_by,
            last_changed_at       = @u-last_changed_at,
            local_last_changed_at = @u-local_last_changed_at
        WHERE travel_id = @u-travel_id.
    ENDLOOP.
    LOOP AT lhc_Travel=>mt_delete INTO DATA(d).
      DELETE FROM ztravel_um_fs01 WHERE travel_id = @d-travel_id.
    ENDLOOP.
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
    CLEAR: lhc_Travel=>mt_create, lhc_Travel=>mt_update, lhc_Travel=>mt_delete.
  ENDMETHOD.
ENDCLASS.
