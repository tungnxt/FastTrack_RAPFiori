@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Item - Interface View'
@Metadata.ignorePropagatedAnnotations: true
define view entity zi_bkitem_fs01
  as select from zbkitem_fs01
  association to parent zi_booking_fs01 as _bookingHeader on $projection.BookingId = _bookingHeader.BookingId
{
  key booking_id            as BookingId,
  key item_id               as ItemId,
      product_id            as ProductId,
      @Semantics.quantity.unitOfMeasure: 'QuantityUnit'
      quantity              as Quantity,
      quantity_unit         as QuantityUnit,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      item_price            as ItemPrice,
      currency_code         as CurrencyCode,
      last_changed_at       as LastChangedAt,
      local_last_changed_at as LocalLastChangedAt,
      _bookingHeader
}
    
