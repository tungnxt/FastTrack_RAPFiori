CLASS zcl_bookingnode_tf DEFINITION
  PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_amdp_marker_hdb.
    CLASS-METHODS get_nodes FOR TABLE FUNCTION ztf_bookingnode_fs01.
ENDCLASS.

CLASS zcl_bookingnode_tf IMPLEMENTATION.
  METHOD get_nodes BY DATABASE FUNCTION FOR HDB
                   LANGUAGE SQLSCRIPT
                   OPTIONS READ-ONLY
                   USING zbooking_fs01 zbkitem_fs01.

    -- Aggregate items per booking (roll-up total + count) : this is the "logic"
    lt_agg = SELECT booking_id,
                    sum( item_price ) AS sum_amount,
                    COUNT(*)          AS child_count
               FROM zbkitem_fs01
              GROUP BY booking_id;

    RETURN
      -- LEVEL 1: header node (rolled-up amount + 10% vat + child count)
      SELECT '100' AS client,
             h.booking_id                                   as NodeId,
             ''                                             as ParentNodeId,
             'H'                                            as NodeType,
             h.booking_id                                   as BookingId,
             '0000'                                         as ItemId,
             h.description                                  as Title,
             ''                                             as ProductId,
             coalesce( a.sum_amount, h.total_price )        as Amount,
             coalesce( a.sum_amount, h.total_price ) * 1.1  AS AmountInclVat,
             coalesce( a.child_count, 0 )                   as ChildCount,
             h.currency_code                                as CurrencyCode,
             h.overall_status                               as OverallStatus,
             0                                              as StatusCriticality
        from zbooking_fs01 as h
        left outer join :lt_agg as a on a.booking_id = h.booking_id
      union all
      -- LEVEL 2: item node (per-row vat)
      SELECT '100' AS client,
             i.booking_id || '-' || i.item_id               as NodeId,
             i.booking_id                                   as ParentNodeId,
             'I'                                            as NodeType,
             i.booking_id                                   as BookingId,
             i.item_id                                      as ItemId,
             i.product_id                                   as Title,
             i.product_id                                   as ProductId,
             i.item_price                                   as Amount,
             i.item_price * 1.1                             AS AmountInclVat,
             0                                              AS ChildCount,
             i.currency_code                                as CurrencyCode,
             ''                                             as OverallStatus,
             0                                              as StatusCriticality
        from zbkitem_fs01 as i;
  endmethod.
ENDCLASS.
