@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Tree TF - hierarchy source'
@OData.hierarchy.recursiveHierarchy: [{ entity.name: 'ZH_BOOKNODETF_FS01' }]
define root view entity ZI_BOOKNODETF_FS01
  as select from ZTF_BOOKINGNODE_FS01 as node
  association [0..1] to ZI_BOOKNODETF_FS01 as _Parent on $projection.ParentNodeId = _Parent.NodeId
    -- NEW: children come from a CUSTOM ENTITY (navigation-only, resolved at runtime)
  association [0..*] to ZCE_NODECHILD_FS01 as _Children
    on  $projection.NodeId = _Children.ParentNodeId
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
      @Semantics.amount.currencyCode: 'CurrencyCode'
      node.AmountInclVat,
      node.ChildCount,
      node.CurrencyCode,
      node.OverallStatus,
      node.StatusCriticality,
      _Parent,
      _Children
}
