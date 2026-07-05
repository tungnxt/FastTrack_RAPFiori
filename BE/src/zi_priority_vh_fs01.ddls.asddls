@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Priority - VH from domain fixed values'
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZI_PRIORITY_VH_FS01
  as select from    DDCDS_CUSTOMER_DOMAIN_VALUE(
                      p_domain_name : 'ZD_PRIORITY_FS01' ) as Values
    left outer join DDCDS_CUSTOMER_DOMAIN_VALUE_T(
                      p_domain_name : 'ZD_PRIORITY_FS01' ) as Texts on  Texts.domain_name    = Values.domain_name
                                                                    and Texts.value_position = Values.value_position
                                                                    and Texts.language       = $session.system_language
{
      @ObjectModel.text.element: [ 'Description' ]
      @UI.textArrangement: #TEXT_LAST
  key Values.value_low as Priority,

      Texts.text       as Description
}
