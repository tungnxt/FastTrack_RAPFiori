@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'City - Value Help (distinct)'
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZI_CITY_VH_FS01
  as select distinct from zcustomer_fs01
{
      -- distinct city list from the customer master
  key city as City
}
