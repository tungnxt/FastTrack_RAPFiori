@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection Booking'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true

-- T17 Semantic Key: BookingId is displayed BOLD in the list,
-- and draft "unsaved changes" indicator is anchored to it
@ObjectModel.semanticKey: ['BookingId']

-- T02: enable the free-text search field of the list report
@Search.searchable: true
define root view entity ZC_BOOKING_FS01
  provider contract transactional_query
  as projection on ZI_BOOKING_FS01
{
  key BookingId,

      -- T05 Text Arrangement step 1: attach the text element to the ID.
      -- Step 2 (@UI.textArrangement) is done in metadata extension _T05.
      -- NOTE: the value help for CustomerId is declared ONLY in extension
      -- _T03 (cascading variant) - do NOT duplicate it here, duplicated
      -- annotations on the same layer cause unpredictable overrides.
      @ObjectModel.text.element: ['CustomerName']
      CustomerId,

      BookingDate,
      Description,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalPrice,
      CurrencyCode,

      -- T10.2: value help view with #XS -> DROPDOWN (not popup);
      -- text association lets us show 'New/Accepted/Cancelled' instead of N/A/X
      @ObjectModel.text.element: ['StatusText']
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_BOOKING_STATUS_VH_FS01',
                                                     element: 'OverallStatus' },
                                           useForValidation: true }]
      OverallStatus,

      -- ===== NEW FIELDS =====
      -- T10.1: NO value-help annotation needed! The dropdown comes from
      -- the DOMAIN FIXED VALUES of data elements ZE_CONFIRM_FS01 / ZE_PRIORITY_FS01
      ConfirmFlag,
      Priority,

      CustomerRating,
      CompletionPct,
      StatusCriticality,
      PriorityCriticality,
      -- ======================

      -- denormalized customer attributes for field groups & contact demo
      _customer.CustomerName as CustomerName,
      _status.StatusText     as StatusText,
      @Semantics.eMail.address: true
      _customer.Email        as CustomerEmail,
      _customer.City         as CustomerCity,

      /* Associations */
      _bookingItem : redirected to composition child ZC_BKITEM_FS01,
      _customer,
      _status
}
