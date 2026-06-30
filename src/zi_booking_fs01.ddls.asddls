@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking - Interface View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity zi_booking_fs01
  as select from zbooking_fs01
  composition [0..*] of zi_bkitem_fs01   as _bookingItem
  association [0..1] to ZI_CUSTOMER_FS01 as _customer on $projection.CustomerId = _customer.CustomerId
{
  key booking_id            as BookingId,
      customer_id           as CustomerId,
      booking_date          as BookingDate,
      description           as Description,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      total_price           as TotalPrice,
      currency_code         as CurrencyCode,
      overall_status        as OverallStatus,
      
      created_by            as CreatedBy,
      created_at            as CreatedAt,
      last_changed_by       as LastChangedBy,
      last_changed_at       as LastChangedAt,
      local_last_changed_at as LocalLastChangedAt,
      _bookingItem,
      _customer // Make association public
}
