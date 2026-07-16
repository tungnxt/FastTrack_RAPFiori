CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Travel RESULT result.
ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.
ENDCLASS.

CLASS lsc_ZI_TRAVEL_AS_FS01 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save_modified   REDEFINITION.
    METHODS cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_ZI_TRAVEL_AS_FS01 IMPLEMENTATION.
  METHOD save_modified.
    " Framework DA tu luu ZTRAVEL_AS_FS01 -> o day chi GHI THEM log.
    DATA lt_log TYPE STANDARD TABLE OF ztravel_log_fs01.
    GET TIME STAMP FIELD DATA(lv_now).

    LOOP AT create-travel INTO DATA(ls_c).
      APPEND VALUE #( log_uuid   = xco_cp=>uuid( )->value
                      travel_id  = ls_c-TravelId operation = 'CREATE'
                      changed_at = lv_now
                      changed_by = sy-uname ) TO lt_log.
    ENDLOOP.
    LOOP AT update-travel INTO DATA(ls_u).
      APPEND VALUE #( log_uuid   = xco_cp=>uuid( )->value
                      travel_id  = ls_u-TravelId operation = 'UPDATE'
                      changed_at = lv_now
                      changed_by = sy-uname ) TO lt_log.
    ENDLOOP.
    LOOP AT delete-travel INTO DATA(ls_d).
      APPEND VALUE #( log_uuid   = xco_cp=>uuid( )->value
                      travel_id  = ls_d-TravelId operation = 'DELETE'
                      changed_at = lv_now
                      changed_by = sy-uname ) TO lt_log.
    ENDLOOP.

    IF lt_log IS NOT INITIAL.
      INSERT ztravel_log_fs01 FROM TABLE @lt_log.
    ENDIF.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.
ENDCLASS.
