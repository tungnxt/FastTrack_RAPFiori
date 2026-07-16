CLASS zcl_booking_eml_demo_fs01 DEFINITION
  PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PRIVATE SECTION.
    METHODS demo_read          IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS demo_read_children IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS demo_create        IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS demo_update        IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS demo_update_item   IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS demo_delete        IMPORTING out TYPE REF TO if_oo_adt_classrun_out.

    CONSTANTS c_read_id   TYPE c LENGTH 10 VALUE 'BK0001'.
    CONSTANTS c_delete_id TYPE c LENGTH 10 VALUE 'BK0005'.
ENDCLASS.


CLASS zcl_booking_eml_demo_fs01 IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    out->write( |=== EML STANDALONE DEMO (Buổi 4 · P4) ===| ).

    demo_read( out ).
    demo_read_children( out ).

    " demo_create( out ).
    " demo_update( out ).
    " demo_update_item( out ).
    " demo_delete( out ).
  ENDMETHOD.


  METHOD demo_read.
    out->write( |--- B07: READ header { c_read_id } ---| ).

    READ ENTITIES OF zi_booking_fs01
      ENTITY Booking
        ALL FIELDS WITH VALUE #( ( BookingId = c_read_id ) )
        RESULT DATA(lt_booking)
      FAILED   DATA(ls_failed)
      REPORTED DATA(ls_reported).

    IF ls_failed IS NOT INITIAL.
      out->write( |READ FAILED ({ c_read_id })| ).
      RETURN.
    ENDIF.

    out->write( lt_booking ).
  ENDMETHOD.


  METHOD demo_read_children.
    out->write( |--- B07b: READ items của { c_read_id } ---| ).

    READ ENTITIES OF zi_booking_fs01
      ENTITY Booking BY \_bookingItem
        ALL FIELDS WITH VALUE #( ( BookingId = c_read_id ) )
        RESULT DATA(lt_items)
      FAILED   DATA(ls_failed)
      REPORTED DATA(ls_reported).

    out->write( lt_items ).
  ENDMETHOD.


  METHOD demo_create.
    out->write( |--- B08: DEEP CREATE (header + 1 item) ---| ).

    MODIFY ENTITIES OF zi_booking_fs01
      ENTITY Booking
        CREATE FIELDS ( CustomerId BookingDate Description
                        TotalPrice CurrencyCode OverallStatus )
        WITH VALUE #( (
          %cid          = 'BK_NEW_1'
          CustomerId    = 'C001'
          BookingDate   = cl_abap_context_info=>get_system_date( )
          Description    = 'Created via EML'
          TotalPrice     = 100
          CurrencyCode   = 'USD'
          OverallStatus  = 'N' ) )

      ENTITY Booking
        CREATE BY \_bookingItem
        FIELDS ( ItemId ProductId Quantity QuantityUnit ItemPrice CurrencyCode )
        WITH VALUE #( (
          %cid_ref = 'BK_NEW_1'
          %target  = VALUE #( (
            %cid         = 'IT_1'
            ItemId       = '0010'
            ProductId    = 'P-100'
            Quantity     = 2
            QuantityUnit = 'EA'
            ItemPrice    = 50
            CurrencyCode = 'USD' ) ) ) )

      MAPPED   DATA(ls_mapped)
      FAILED   DATA(ls_failed)
      REPORTED DATA(ls_reported).

    IF ls_failed IS NOT INITIAL.
      out->write( |CREATE FAILED| ).
      out->write( ls_reported-booking ).
      RETURN.
    ENDIF.

    COMMIT ENTITIES RESPONSE OF zi_booking_fs01
      FAILED   DATA(ls_commit_failed)
      REPORTED DATA(ls_commit_reported).

    IF ls_commit_failed IS INITIAL.
      out->write( |Created BookingId = { ls_mapped-booking[ 1 ]-BookingId }| ).
    ELSE.
      out->write( |COMMIT FAILED| ).
      out->write( ls_commit_reported-booking ).
    ENDIF.
  ENDMETHOD.


  METHOD demo_update.
    out->write( |--- B09a: UPDATE header { c_read_id } ---| ).

    MODIFY ENTITIES OF zi_booking_fs01
      ENTITY Booking
        UPDATE FIELDS ( Description TotalPrice )
        WITH VALUE #( ( BookingId   = c_read_id
                        Description  = 'Updated via EML'
                        TotalPrice   = 250 ) )
      FAILED   DATA(ls_failed)
      REPORTED DATA(ls_reported).

    IF ls_failed IS NOT INITIAL.
      out->write( |UPDATE FAILED| ).
      out->write( ls_reported-booking ).
      RETURN.
    ENDIF.

    COMMIT ENTITIES RESPONSE OF zi_booking_fs01
      FAILED   DATA(ls_cf)
      REPORTED DATA(ls_cr).

    out->write( COND #( WHEN ls_cf IS INITIAL
                        THEN |Updated OK| ELSE |Update COMMIT failed| ) ).
  ENDMETHOD.


  METHOD demo_update_item.
    out->write( |--- B09b: UPDATE item (BookingId={ c_read_id }, ItemId=0010) ---| ).

    MODIFY ENTITIES OF zi_booking_fs01
      ENTITY BookingItem
        UPDATE FIELDS ( Quantity ItemPrice )
        WITH VALUE #( ( BookingId = c_read_id
                        ItemId    = '0010'
                        Quantity  = 5
                        ItemPrice = 45 ) )
      FAILED   DATA(ls_failed)
      REPORTED DATA(ls_reported).

    IF ls_failed IS NOT INITIAL.
      out->write( |UPDATE ITEM FAILED| ).
      out->write( ls_reported-bookingitem ).
      RETURN.
    ENDIF.

    COMMIT ENTITIES RESPONSE OF zi_booking_fs01
      FAILED   DATA(ls_cf)
      REPORTED DATA(ls_cr).

    out->write( COND #( WHEN ls_cf IS INITIAL
                        THEN |Item updated OK| ELSE |Item COMMIT failed| ) ).
  ENDMETHOD.


  METHOD demo_delete.
    out->write( |--- B09c: DELETE header { c_delete_id } ---| ).

    MODIFY ENTITIES OF zi_booking_fs01
      ENTITY Booking
        DELETE FROM VALUE #( ( BookingId = c_delete_id ) )
      FAILED   DATA(ls_failed)
      REPORTED DATA(ls_reported).

    IF ls_failed IS NOT INITIAL.
      out->write( |DELETE FAILED| ).
      out->write( ls_reported-booking ).
      RETURN.
    ENDIF.

    COMMIT ENTITIES RESPONSE OF zi_booking_fs01
      FAILED   DATA(ls_cf)
      REPORTED DATA(ls_cr).

    out->write( COND #( WHEN ls_cf IS INITIAL
                        THEN |Deleted OK| ELSE |Delete COMMIT failed| ) ).
  ENDMETHOD.

ENDCLASS.
