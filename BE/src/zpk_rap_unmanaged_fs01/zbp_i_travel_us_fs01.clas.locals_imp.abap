*"* local helper classes for UNMANAGED SAVE

"=====================================================================
" UNMANAGED SAVE (with unmanaged save)
"   - Framework KHONG tu luu -> save_modified chiu trach nhiem 100%.
"   - (a) Persist bang chinh ZTRAVEL_US_FS01 bang tay.
"   - (b) Goi sang BO MANAGED (ZI_TRAVEL_MG_FS01) qua EML de xu ly luon
"         -> minh hoa "wrap/delegate mot managed BO trong save_modified"
"            (dung y tuong RAP610, nhung goi BO managed noi bo thay vi released API).
"   QUY TAC VANG: EML/COMMIT chi o day, KHONG o handler interaction.
"=====================================================================
CLASS lsc_travel_us DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save_modified REDEFINITION.
ENDCLASS.

CLASS lsc_travel_us IMPLEMENTATION.
  METHOD save_modified.

    "---------- (a) TU PERSIST BANG CHINH ----------
    " CREATE -> INSERT
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
          created_at            = utclong_current( )
          last_changed_by       = sy-uname
          last_changed_at       = utclong_current( )
          local_last_changed_at = utclong_current( ) ) ).
      INSERT ztravel_us_fs01 FROM TABLE @lt_ins.
    ENDIF.

    " UPDATE -> UPDATE
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
            last_changed_at       = @( utclong_current( ) ),
            local_last_changed_at = @( utclong_current( ) )
        WHERE travel_id = @u-TravelId.
    ENDLOOP.

    " DELETE -> DELETE
    LOOP AT delete-travel INTO DATA(d).
      DELETE FROM ztravel_us_fs01 WHERE travel_id = @d-TravelId.
    ENDLOOP.

    "---------- (b) DELEGATE sang BO MANAGED qua EML ----------
    " Voi moi Travel moi tao -> tao 1 ban ghi tuong ung ben BO managed.
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
        REPORTED DATA(reported).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
