CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Travel RESULT result.
ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.
ENDCLASS.

CLASS lsc_ZI_TRAVEL_US_FS01 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save_modified   REDEFINITION.
    METHODS cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_ZI_TRAVEL_US_FS01 IMPLEMENTATION.
  METHOD save_modified.
*    DATA(lv_now) = utclong_current( ).    " admin fields kieu UTCLONG
    GET TIME STAMP FIELD DATA(lv_now).

    " (a) 'with unmanaged save' -> framework KHONG tu luu, ta tu persist.
    IF create-travel IS NOT INITIAL.
      DATA lt_ins TYPE STANDARD TABLE OF ztravel_us_fs01.
      lt_ins = VALUE #( FOR c IN create-travel
        ( travel_id      = c-TravelId
          agency_id      = c-AgencyId
          customer_id    = c-CustomerId
          begin_date     = c-BeginDate
          end_date       = c-EndDate
          description    = c-Description
          total_price    = c-TotalPrice
          currency_code  = c-CurrencyCode
          overall_status = c-OverallStatus
          created_by            = sy-uname
          created_at            = lv_now
          last_changed_by       = sy-uname
          last_changed_at       = lv_now
          local_last_changed_at = lv_now ) ).
      INSERT ztravel_us_fs01 FROM TABLE @lt_ins.
    ENDIF.

    LOOP AT update-travel INTO DATA(u).
      UPDATE ztravel_us_fs01
        SET agency_id      = @u-AgencyId,
            customer_id    = @u-CustomerId,
            begin_date     = @u-BeginDate,
            end_date       = @u-EndDate,
            description    = @u-Description,
            total_price    = @u-TotalPrice,
            currency_code  = @u-CurrencyCode,
            overall_status = @u-OverallStatus,
            last_changed_by       = @sy-uname,
            last_changed_at       = @lv_now,
            local_last_changed_at = @lv_now
        WHERE travel_id = @u-TravelId.
    ENDLOOP.

    LOOP AT delete-travel INTO DATA(d).
      DELETE FROM ztravel_us_fs01 WHERE travel_id = @d-TravelId.
    ENDLOOP.

    " (b) DELEGATE sang BO MANAGED qua EML (thay cho Released API).
    IF create-travel IS NOT INITIAL.
      MODIFY ENTITIES OF zi_travel_mg_fs01
        ENTITY Travel
        CREATE FIELDS ( TravelId AgencyId CustomerId BeginDate EndDate
                        Description TotalPrice CurrencyCode OverallStatus )
        WITH VALUE #( FOR c2 IN create-travel
          ( %cid          = |MG_{ c2-TravelId }|
            TravelId       = c2-TravelId
            AgencyId       = c2-AgencyId
            CustomerId     = c2-CustomerId
            BeginDate      = c2-BeginDate
            EndDate        = c2-EndDate
            Description    = c2-Description
            TotalPrice     = c2-TotalPrice
            CurrencyCode   = c2-CurrencyCode
            OverallStatus  = c2-OverallStatus ) )
        MAPPED   DATA(mapped)
        FAILED   DATA(failed)
        REPORTED DATA(lt_reported).
    ENDIF.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.
ENDCLASS.
