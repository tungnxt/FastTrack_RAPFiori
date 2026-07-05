CLASS zcl_nodechild_query DEFINITION
  PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
ENDCLASS.

CLASS zcl_nodechild_query IMPLEMENTATION.
  METHOD if_rap_query_provider~select.

    " 1) Read request (MUST call get_paging / get_sort, else "query not fully covered")
    DATA(lo_paging) = io_request->get_paging( ).
    DATA(lv_top)    = lo_paging->get_page_size( ).
    DATA(lv_skip)   = lo_paging->get_offset( ).
    DATA(lt_sort)   = io_request->get_sort_elements( ).

    " Parent node id comes in as a filter (from the association ON-condition)
    DATA lt_parent_r TYPE if_rap_query_filter=>tt_range_option.
    TRY.
        DATA(lt_ranges) = io_request->get_filter( )->get_as_ranges( ).
        lt_parent_r = VALUE #( lt_ranges[ name = 'PARENTNODEID' ]-range OPTIONAL ).
      CATCH cx_rap_query_filter_no_range.
    ENDTRY.

    " 2) Fetch children from the table function (children = nodes with parent = requested node)
    DATA lt_children TYPE STANDARD TABLE OF zce_nodechild_fs01 WITH EMPTY KEY.
    SELECT nodeid, parentnodeid, title, nodetype, bookingid, itemid,
           productid, amount, amountinclvat, currencycode, overallstatus
      FROM ztf_bookingnode_fs01
      WHERE parentnodeid IN @lt_parent_r
      INTO CORRESPONDING FIELDS OF TABLE @lt_children.

    " 3) Sort ($orderby)
    IF lt_sort IS INITIAL.
      SORT lt_children BY nodeid ASCENDING.
    ELSE.
      LOOP AT lt_sort INTO DATA(ls_sort).
        IF ls_sort-descending = abap_true.
          SORT lt_children BY (ls_sort-element_name) DESCENDING.
        ELSE.
          SORT lt_children BY (ls_sort-element_name) ASCENDING.
        ENDIF.
      ENDLOOP.
    ENDIF.

    " 4) Count (total BEFORE paging)
    IF io_request->is_total_numb_of_rec_requested( ).
      io_response->set_total_number_of_records( lines( lt_children ) ).
    ENDIF.

    " 5) Paging + return data
    IF io_request->is_data_requested( ).
      IF lv_skip > 0.
        DELETE lt_children FROM 1 TO CONV i( lv_skip ).
      ENDIF.
      IF lv_top > 0 AND lines( lt_children ) > lv_top.
        DELETE lt_children FROM CONV i( lv_top ) + 1.
      ENDIF.
      io_response->set_data( lt_children ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
