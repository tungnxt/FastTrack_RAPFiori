@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Tree TF - Hierarchy'
define hierarchy ZH_BOOKNODETF_FS01
  as parent child hierarchy(
    source ZI_BOOKNODETF_FS01
    child to parent association _Parent
    start where
      ParentNodeId is initial
    siblings order by
      NodeId
  )
{
  key NodeId,
      ParentNodeId
}
