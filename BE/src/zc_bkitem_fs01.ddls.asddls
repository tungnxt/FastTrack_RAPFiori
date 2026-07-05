@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Item - Projection'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_BKITEM_FS01
  as projection on zi_bkitem_fs01
{
  key BookingId,
  key ItemId,
      ProductId,
      @Semantics.quantity.unitOfMeasure: 'QuantityUnit'
      Quantity,
      QuantityUnit,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      ItemPrice,
      CurrencyCode,
      LastChangedAt,
      LocalLastChangedAt,
      /* Associations */
      _bookingHeader : redirected to parent ZC_BOOKING_FS01
}
