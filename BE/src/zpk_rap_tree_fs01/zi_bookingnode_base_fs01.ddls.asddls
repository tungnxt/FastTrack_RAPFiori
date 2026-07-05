@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Tree - Node Union (base)'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_BOOKINGNODE_BASE_FS01
  as select from ZI_BOOKING_FS01 as h -- LEVEL 1: Booking header = root node
{
      -- Node key: for a header the node id is simply the BookingId
  key cast( h.BookingId as abap.char( 40 ) )    as NodeId,
      -- Empty parent id => this row is a top / root node of the tree
      cast( '' as abap.char( 40 ) )             as ParentNodeId,
      -- Node type flag ('H' = header) so the UI can format rows differently
      cast( 'H' as abap.char( 1 ) )             as NodeType,
      h.BookingId                               as BookingId,
      -- Header has no item id -> keep empty, same type/length as the item branch
      cast( '' as abap.numc( 4 ) )              as ItemId,
      -- Display title of the node: header shows its Description
      cast( h.Description as abap.char( 128 ) ) as Title,
      cast( '' as abap.char( 40 ) )             as ProductId,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      h.TotalPrice                              as Amount,
      h.CurrencyCode                            as CurrencyCode,
      h.OverallStatus                           as OverallStatus,
      h.StatusCriticality                       as StatusCriticality
}
union all select from zi_bkitem_fs01 as i -- LEVEL 2: Item = child node of its header
{
      -- Node key for an item = "<BookingId>-<ItemId>" (must stay unique across the set)
  key cast( concat( concat( i.BookingId, '-' ), i.ItemId ) as abap.char( 40 ) ) as NodeId,
      -- Parent id points to the header node id (= BookingId)
      cast( i.BookingId as abap.char( 40 ) )                                    as ParentNodeId,
      cast( 'I' as abap.char( 1 ) )                                             as NodeType,
      i.BookingId                                                               as BookingId,
      i.ItemId                                                                  as ItemId,
      -- Item shows its ProductId as the node title
      cast( i.ProductId as abap.char( 128 ) )                                   as Title,
      i.ProductId                                                               as ProductId,
      i.ItemPrice                                                               as Amount,
      i.CurrencyCode                                                            as CurrencyCode,
      cast( '' as abap.char( 1 ) )                                              as OverallStatus,
      cast( 0 as abap.int1 )                                                    as StatusCriticality
}
