CLASS zcl_booking_data_gen DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_booking_data_gen IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    "============================================================
    " 1) CUSTOMERS — MODIFY (insert nếu mới, update nếu đã có)
    "============================================================
   MODIFY zcustomer_fs01 FROM TABLE @( VALUE #(
      ( customer_id = 'C001' customer_name = 'Acme Corp'   email = 'sales@acme.example'   city = 'Hanoi' )
      ( customer_id = 'C002' customer_name = 'Globex Ltd'  email = 'info@globex.example'  city = 'Da Nang' )
      ( customer_id = 'C003' customer_name = 'Initech JSC' email = 'hello@initech.example' city = 'HCMC' ) ) ).
    out->write( |Customers modified: { sy-dbcnt } rows| ).
*
    "============================================================
    " 2) BOOKINGS (header) — MODIFY
    "============================================================
    MODIFY zbooking_fs01 FROM TABLE @( VALUE #(
      ( booking_id = 'BK0001' customer_id = 'C001' booking_date = '20260601'
        description = 'Hardware order'    total_price = '1500.00' currency_code = 'USD' overall_status = 'N' )
      ( booking_id = 'BK0002' customer_id = 'C002' booking_date = '20260605'
        description = 'Software licenses' total_price = '8200.00' currency_code = 'USD' overall_status = 'A' )
      ( booking_id = 'BK0003' customer_id = 'C001' booking_date = '20260610'
        description = 'Consulting'        total_price = '4300.00' currency_code = 'EUR' overall_status = 'N' )
    ) ).
    out->write( |Bookings modified: { sy-dbcnt } rows| ).

    "============================================================
    " 3) ITEMS — MODIFY
    "============================================================
    MODIFY zbkitem_fs01 FROM TABLE @( VALUE #(
      quantity_unit = 'EA'
      ( booking_id = 'BK0001' item_id = '0010' product_id = 'LAPTOP-14'   quantity = '5'  item_price = '200.00' currency_code = 'USD' )
      ( booking_id = 'BK0001' item_id = '0020' product_id = 'MOUSE'       quantity = '5'  item_price = '100.00' currency_code = 'USD' )
      ( booking_id = 'BK0002' item_id = '0010' product_id = 'OFFICE-LIC'  quantity = '40' item_price = '180.00' currency_code = 'USD' )
      ( booking_id = 'BK0003' item_id = '0010' product_id = 'CONSULT-DAY' quantity = '10' item_price = '430.00' currency_code = 'EUR' )
    ) ).
    out->write( |Items modified: { sy-dbcnt } rows| ).

    out->write( 'Demo data ready. Mở ZI_Booking > Data Preview (F8) để xem.' ).

  ENDMETHOD.
ENDCLASS.
