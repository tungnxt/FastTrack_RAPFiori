@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking - Interface View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_BOOKING_FS01
  as select from zbooking_fs01
  composition [0..*] of zi_bkitem_fs01            as _bookingItem
  association [0..1] to ZI_CUSTOMER_FS01          as _customer on $projection.CustomerId = _customer.CustomerId
  association [0..1] to ZI_BOOKING_STATUS_VH_FS01 as _status   on $projection.OverallStatus = _status.OverallStatus
{
  key booking_id            as BookingId,
      customer_id           as CustomerId,
      booking_date          as BookingDate,
      description           as Description,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      total_price           as TotalPrice,
      currency_code         as CurrencyCode,
      overall_status        as OverallStatus,

      -- ===== NEW FIELDS =====
      confirm_flag          as ConfirmFlag,
      priority              as Priority,
      customer_rating       as CustomerRating,
      completion_pct        as CompletionPct,

      -- T07 (way 2.1 - CASE WHEN): numeric criticality computed on the DB.
      -- 0 neutral(grey) / 1 negative(red) / 2 critical(yellow) / 3 positive(green)
      case overall_status
        when 'N' then 2        -- New       -> yellow (needs attention)
        when 'A' then 3        -- Accepted  -> green
        when 'X' then 1        -- Cancelled -> red
        else 0
      end                   as StatusCriticality,

      -- Same trick for Priority: High=red, Medium=yellow, Low=green
      case priority
        when '3' then 1        -- High   -> red
        when '2' then 2        -- Medium -> yellow
        when '1' then 3        -- Low    -> green
        else 0
      end                   as PriorityCriticality,
      -- ======================

      created_by            as CreatedBy,
      created_at            as CreatedAt,
      last_changed_by       as LastChangedBy,
      last_changed_at       as LastChangedAt,
      local_last_changed_at as LocalLastChangedAt,

      _bookingItem,
      _customer,
      _status
}
