@EndUserText.label: 'Booking Tree - Child Nodes (Custom Entity)'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_NODECHILD_QUERY'
define custom entity ZCE_NODECHILD_FS01
{
  key NodeId        : abap.char( 40 );
      ParentNodeId  : abap.char( 40 );

      @UI.lineItem  : [{ position: 10, label: 'Booking / Product' }]
      Title         : abap.char( 128 );
      NodeType      : abap.char( 1 );
      BookingId     : abap.char( 10 );
      ItemId        : abap.numc( 4 );
      ProductId     : abap.char( 40 );

      @Semantics.amount.currencyCode: 'CurrencyCode'
      @UI.lineItem  : [{ position: 20, label: 'Amount' }]
      Amount        : abap.curr( 15, 2 );

      @Semantics.amount.currencyCode: 'CurrencyCode'
      @UI.lineItem  : [{ position: 25, label: 'Amount incl. VAT' }]
      AmountInclVat : abap.curr( 15, 2 );

      CurrencyCode  : abap.cuky;

      @UI.lineItem  : [{ position: 40, label: 'Status' }]
      OverallStatus : abap.char( 1 );
}
