CLASS zcl_booking_eml_tables_fs01 DEFINITION
  PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PRIVATE SECTION.
    METHODS demo_read    IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS demo_create  IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS demo_update  IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS demo_delete  IMPORTING out TYPE REF TO if_oo_adt_classrun_out.

    CONSTANTS c_read_id   TYPE c LENGTH 10 VALUE 'BK0001'.
    CONSTANTS c_delete_id TYPE c LENGTH 10 VALUE 'BK0005'.
ENDCLASS.


CLASS zcl_booking_eml_tables_fs01 IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    out->write( |=== EML DERIVED-TABLE DEMO (Buổi 4 · P4) ===| ).

    demo_read( out ).
    " demo_create( out ).
    " demo_update( out ).
    " demo_delete( out ).
  ENDMETHOD.


  METHOD demo_read.
    out->write( |--- READ header { c_read_id } (typed key table) ---| ).

    DATA lt_keys TYPE TABLE FOR READ IMPORT zi_booking_fs01.
    lt_keys = VALUE #(
      ( BookingId = c_read_id )
    ).

    DATA lt_booking TYPE TABLE FOR READ RESULT zi_booking_fs01.

    READ ENTITIES OF zi_booking_fs01
      ENTITY Booking
        ALL FIELDS
        WITH lt_keys
        RESULT   lt_booking
      FAILED   DATA(ls_failed)
      REPORTED DATA(ls_reported).

    IF ls_failed IS NOT INITIAL.
      out->write( |READ FAILED ({ c_read_id })| ).
      RETURN.
    ENDIF.

    out->write( lt_booking ).
  ENDMETHOD.


  METHOD demo_create.
    out->write( |--- CREATE deep (typed create tables) ---| ).

    DATA lt_create TYPE TABLE FOR CREATE zi_booking_fs01.
    lt_create = VALUE #(
      ( %cid          = 'BK_NEW_1'
        CustomerId    = 'C001'
        BookingDate   = cl_abap_context_info=>get_system_date( )
        Description    = 'Created via EML (typed table)'
        TotalPrice     = 100
        CurrencyCode   = 'USD'
        OverallStatus  = 'N' )
    ).

    DATA lt_item_create TYPE TABLE FOR CREATE zi_booking_fs01\_bookingItem.
    lt_item_create = VALUE #(
      ( %cid_ref = 'BK_NEW_1'
        %target  = VALUE #(
          ( %cid         = 'IT_1'
            ItemId       = '0010'
            ProductId    = 'P-100'
            Quantity     = 2
            QuantityUnit = 'EA'
            ItemPrice    = 50
            CurrencyCode = 'USD' ) ) )
    ).

    DATA ls_mapped   TYPE RESPONSE FOR MAPPED   zi_booking_fs01.
    DATA ls_failed   TYPE RESPONSE FOR FAILED   zi_booking_fs01.
    DATA ls_reported TYPE RESPONSE FOR REPORTED zi_booking_fs01.

    MODIFY ENTITIES OF zi_booking_fs01
      ENTITY Booking
        CREATE FIELDS ( CustomerId BookingDate Description
                        TotalPrice CurrencyCode OverallStatus )
        WITH lt_create
      ENTITY Booking
        CREATE BY \_bookingItem
        FIELDS ( ItemId ProductId Quantity QuantityUnit ItemPrice CurrencyCode )
        WITH lt_item_create
      MAPPED   ls_mapped
      FAILED   ls_failed
      REPORTED ls_reported.

    IF ls_failed IS NOT INITIAL.
      out->write( |CREATE FAILED| ).
      out->write( ls_reported-booking ).
      RETURN.
    ENDIF.

    DATA ls_c_failed   TYPE RESPONSE FOR FAILED   LATE zi_booking_fs01.
    DATA ls_c_reported TYPE RESPONSE FOR REPORTED LATE zi_booking_fs01.

    COMMIT ENTITIES RESPONSE OF zi_booking_fs01
      FAILED   ls_c_failed
      REPORTED ls_c_reported.

    IF ls_c_failed IS INITIAL.
      out->write( |Created BookingId = { ls_mapped-booking[ 1 ]-BookingId }| ).
    ELSE.
      out->write( |COMMIT FAILED| ).
      out->write( ls_c_reported-booking ).
    ENDIF.
  ENDMETHOD.


  METHOD demo_update.
    out->write( |--- UPDATE header { c_read_id } (typed update table) ---| ).

    DATA lt_update TYPE TABLE FOR UPDATE zi_booking_fs01.
    lt_update = VALUE #(
      ( BookingId   = c_read_id
        Description  = 'Updated via EML (typed table)'
        TotalPrice   = 250
        %control-Description = if_abap_behv=>mk-on
        %control-TotalPrice  = if_abap_behv=>mk-on )
    ).

    DATA ls_failed   TYPE RESPONSE FOR FAILED   zi_booking_fs01.
    DATA ls_reported TYPE RESPONSE FOR REPORTED zi_booking_fs01.

    MODIFY ENTITIES OF zi_booking_fs01
      ENTITY Booking
        UPDATE SET FIELDS
        WITH lt_update
      FAILED   ls_failed
      REPORTED ls_reported.

    IF ls_failed IS NOT INITIAL.
      out->write( |UPDATE FAILED| ).
      out->write( ls_reported-booking ).
      RETURN.
    ENDIF.

    DATA ls_c_failed   TYPE RESPONSE FOR FAILED   LATE zi_booking_fs01.
    DATA ls_c_reported TYPE RESPONSE FOR REPORTED LATE zi_booking_fs01.

    COMMIT ENTITIES RESPONSE OF zi_booking_fs01
      FAILED   ls_c_failed
      REPORTED ls_c_reported.

    out->write( COND #( WHEN ls_c_failed IS INITIAL
                        THEN |Updated OK| ELSE |Update COMMIT failed| ) ).
  ENDMETHOD.


  METHOD demo_delete.
    out->write( |--- DELETE header { c_delete_id } (typed delete table) ---| ).

    DATA lt_delete TYPE TABLE FOR DELETE zi_booking_fs01.
    lt_delete = VALUE #(
      ( BookingId = c_delete_id )
    ).

    DATA ls_failed   TYPE RESPONSE FOR FAILED   zi_booking_fs01.
    DATA ls_reported TYPE RESPONSE FOR REPORTED zi_booking_fs01.

    MODIFY ENTITIES OF zi_booking_fs01
      ENTITY Booking
        DELETE FROM lt_delete
      FAILED   ls_failed
      REPORTED ls_reported.

    IF ls_failed IS NOT INITIAL.
      out->write( |DELETE FAILED| ).
      out->write( ls_reported-booking ).
      RETURN.
    ENDIF.

    DATA ls_c_failed   TYPE RESPONSE FOR FAILED   LATE zi_booking_fs01.
    DATA ls_c_reported TYPE RESPONSE FOR REPORTED LATE zi_booking_fs01.

    COMMIT ENTITIES RESPONSE OF zi_booking_fs01
      FAILED   ls_c_failed
      REPORTED ls_c_reported.

    out->write( COND #( WHEN ls_c_failed IS INITIAL
                        THEN |Deleted OK| ELSE |Delete COMMIT failed| ) ).
  ENDMETHOD.

ENDCLASS.
