@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Confirm Flag - VH from domain fixed values'
-- #XS -> render as DROPDOWN instead of an F4 popup dialog
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZI_CONFIRM_VH_FS01
  as select from    DDCDS_CUSTOMER_DOMAIN_VALUE(
                      p_domain_name : 'ZD_CONFIRM_FS01' ) as Values
    left outer join DDCDS_CUSTOMER_DOMAIN_VALUE_T(
                      p_domain_name : 'ZD_CONFIRM_FS01' ) as Texts on  Texts.domain_name    = Values.domain_name
                                                                   and Texts.value_position = Values.value_position
                                                                   and Texts.language       = $session.system_language
{
      -- show 'X (Confirmed)' style: text attached to the key value
      @ObjectModel.text.element: [ 'Description' ]
      @UI.textArrangement: #TEXT_LAST
  key Values.value_low as ConfirmFlag,

      Texts.text       as Description
}
