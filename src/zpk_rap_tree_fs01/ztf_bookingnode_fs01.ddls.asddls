@EndUserText.label: 'Booking Tree - Table Function'
@ClientHandling.type: #CLIENT_DEPENDENT
@ClientHandling.algorithm: #SESSION_VARIABLE

define table function ZTF_BOOKINGNODE_FS01
returns
{
  key client            : abap.clnt;
  key NodeId            : abap.char(40);
      ParentNodeId      : abap.char(40);
      NodeType          : abap.char(1);
      BookingId         : abap.char(10);
      ItemId            : abap.numc(4);
      Title             : abap.char(128);
      ProductId         : abap.char(40);

      @Semantics.amount.currencyCode: 'CurrencyCode'
      Amount            : abap.curr(15,2);

      @Semantics.amount.currencyCode: 'CurrencyCode'
      AmountInclVat     : abap.curr(15,2);

      ChildCount        : abap.int4;
      CurrencyCode      : abap.cuky;
      OverallStatus     : abap.char(1);
      StatusCriticality : abap.int1;
}
implemented by method
  zcl_bookingnode_tf=>get_nodes;