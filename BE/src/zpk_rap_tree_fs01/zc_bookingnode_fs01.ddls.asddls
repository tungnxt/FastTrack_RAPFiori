@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Tree - Projection'
@Metadata.allowExtensions: true

-- REQUIRED: tells OData V4 to build a recursive hierarchy from the define-hierarchy view.
-- This is what generates Aggregation.RecursiveHierarchy / Hierarchy.RecursiveHierarchy in $metadata.
@OData.hierarchy.recursiveHierarchy: [{ entity.name: 'ZH_BOOKINGNODE_FS01' }]

define root view entity ZC_BOOKINGNODE_FS01
  provider contract transactional_query
  as projection on ZI_BOOKINGNODE_FS01
{
  key NodeId,
      ParentNodeId,
      NodeType,
      BookingId,
      ItemId,

      @UI.lineItem: [{ position: 10, label: 'Booking / Product' }]
      Title,

      ProductId,

      @UI.lineItem: [{ position: 20, label: 'Amount' }]
      @Semantics.amount.currencyCode: 'CurrencyCode'
      Amount,
      CurrencyCode,

      @UI.lineItem: [{ position: 30, label: 'Status', criticality: 'StatusCriticality' }]
      OverallStatus,
      StatusCriticality,

      -- REQUIRED: expose the self-association so OData has the parent navigation property.
      -- Without this, RAP silently drops the whole recursive-hierarchy annotation.
      _Parent : redirected to ZC_BOOKINGNODE_FS01
}
