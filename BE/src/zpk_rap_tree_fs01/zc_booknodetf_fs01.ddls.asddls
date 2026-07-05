@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Tree TF - Projection'
@Metadata.allowExtensions: true

@OData.hierarchy.recursiveHierarchy: [{ entity.name: 'ZH_BOOKNODETF_FS01' }]
@UI.headerInfo: { typeName: 'Booking Node', typeNamePlural: 'Booking Tree (TF)', title.value: 'Title' }
@UI.selectionVariant: [{ qualifier: 'TFViewTree', text: 'Table Function Tree' }]


define root view entity ZC_BOOKNODETF_FS01
  provider contract transactional_query
  as projection on ZI_BOOKNODETF_FS01
{
      -- Object Page layout (entity-level annotation, must be in the header)
      @UI.facet: [
        { id: 'General',  purpose: #STANDARD, type: #IDENTIFICATION_REFERENCE,
          label: 'Node Details', position: 10 },
        { id: 'Children', type: #LINEITEM_REFERENCE,
          label: 'Child Nodes', position: 20, targetElement: '_Children' }
      ]

  key NodeId,
      ParentNodeId,

      @UI.identification: [{ position: 5, label: 'Type' }]
      NodeType,

      @UI.identification: [{ position: 6, label: 'Booking ID' }]
      BookingId,

      @UI.identification: [{ position: 7, label: 'Item' }]
      ItemId,

      @UI.lineItem:       [{ position: 10, label: 'Booking / Product' }]
      @UI.identification: [{ position: 10, label: 'Booking / Product' }]
      Title,

      ProductId,

      @UI.lineItem:       [{ position: 20, label: 'Amount' }]
      @UI.identification: [{ position: 20, label: 'Amount' }]
      @Semantics.amount.currencyCode: 'CurrencyCode'
      Amount,

      @UI.lineItem:       [{ position: 25, label: 'Amount incl. VAT' }]
      @UI.identification: [{ position: 25, label: 'Amount incl. VAT' }]
      @Semantics.amount.currencyCode: 'CurrencyCode'
      AmountInclVat,

      @UI.lineItem:       [{ position: 30, label: 'Items' }]
      @UI.identification: [{ position: 30, label: 'Items' }]
      ChildCount,

      CurrencyCode,

      @UI.lineItem:       [{ position: 40, label: 'Status', criticality: 'StatusCriticality' }]
      @UI.identification: [{ position: 40, label: 'Status', criticality: 'StatusCriticality' }]
      OverallStatus,
      StatusCriticality,

      _Parent : redirected to ZC_BOOKNODETF_FS01,
      _Children
}
