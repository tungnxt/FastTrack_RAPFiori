@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Status - Value Help'
@Metadata.ignorePropagatedAnnotations: true
-- #XS tells Fiori the result set is tiny (<= ~10 rows)
-- -> the value help is rendered as a DROPDOWN instead of an F4 popup dialog
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZI_BOOKING_STATUS_VH_FS01
  as select from zstatus_fs01
{
      -- key = the code the booking stores ('N' / 'A' / 'X')
  key status      as OverallStatus,

      -- text shown to the user; paired with @UI.textArrangement #TEXT_ONLY
      -- on the consuming field so users see 'New' instead of 'N'
      @Semantics.text: true
      status_text as StatusText
}
