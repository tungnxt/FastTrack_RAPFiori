*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type declarations

"=====================================================================
" ADDITIONAL SAVE
"   - Framework van TU LUU bang chinh ZTRAVEL_AS_FS01 (managed).
"   - Ta CHI GHI THEM: moi thay doi -> 1 dong log vao ZTRAVEL_LOG_FS01.
"=====================================================================
CLASS lsc_travel_as DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save_modified REDEFINITION.
ENDCLASS.

CLASS lsc_travel_as IMPLEMENTATION.
  METHOD save_modified.
    DATA lt_log TYPE STANDARD TABLE OF ztravel_log_fs01.

    " CREATE
    LOOP AT create-travel INTO DATA(ls_c).
      APPEND VALUE #( log_uuid   = cl_system_uuid=>create_uuid_x16_static( )
                      travel_id  = ls_c-TravelId
                      operation  = 'CREATE'
                      changed_at = utclong_current( )
                      changed_by = sy-uname ) TO lt_log.
    ENDLOOP.

    " UPDATE
    LOOP AT update-travel INTO DATA(ls_u).
      APPEND VALUE #( log_uuid   = cl_system_uuid=>create_uuid_x16_static( )
                      travel_id  = ls_u-TravelId
                      operation  = 'UPDATE'
                      changed_at = utclong_current( )
                      changed_by = sy-uname ) TO lt_log.
    ENDLOOP.

    " DELETE
    LOOP AT delete-travel INTO DATA(ls_d).
      APPEND VALUE #( log_uuid   = cl_system_uuid=>create_uuid_x16_static( )
                      travel_id  = ls_d-TravelId
                      operation  = 'DELETE'
                      changed_at = utclong_current( )
                      changed_by = sy-uname ) TO lt_log.
    ENDLOOP.

    IF lt_log IS NOT INITIAL.
      INSERT ztravel_log_fs01 FROM TABLE @lt_log.   " chi la ghi THEM
    ENDIF.
  ENDMETHOD.
ENDCLASS.
