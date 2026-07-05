@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Tree - Node (hierarchy source)'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_BOOKINGNODE_FS01
  as select from ZI_BOOKINGNODE_BASE_FS01 as node
  association [0..1] to ZI_BOOKINGNODE_FS01 as _Parent on $projection.ParentNodeId = _Parent.NodeId
{
  key node.NodeId,
      node.ParentNodeId,
      node.NodeType,
      node.BookingId,
      node.ItemId,
      node.Title,
      node.ProductId,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      node.Amount,
      node.CurrencyCode,
      node.OverallStatus,
      node.StatusCriticality,
      _Parent
}
