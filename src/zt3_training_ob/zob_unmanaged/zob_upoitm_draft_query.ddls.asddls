@AbapCatalog.viewEnhancementCategory: [ #NONE ]

@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'PO Item Draft Query'

@Metadata.ignorePropagatedAnnotations: true

@ObjectModel.usageType: { serviceQuality: #X, sizeCategory: #S, dataClass: #MIXED }

define view entity zob_upoitm_draft_query
  as select from zob_upoitm_draft

{
  key itemid                        as Itemid,
  key purchaseorderid               as Purchaseorderid,

      itemnumber                    as Itemnumber,
      productid                     as Productid,
      productname                   as Productname,
      quantity                      as Quantity,

      @Semantics.amount.currencyCode: 'itemCurrency'
      unitprice                     as Unitprice,

      @Semantics.amount.currencyCode: 'itemCurrency'
      totalprice                    as Totalprice,

      deliverydate                  as Deliverydate,
      warehouselocation             as Warehouselocation,
      itemcurrency                  as Itemcurrency,
      isurgent                      as Isurgent,
      createdby                     as Createdby,
      createon                      as Createon,
      changedby                     as Changedby,
      changedon                     as Changedon,
      draftentitycreationdatetime   as Draftentitycreationdatetime,
      draftentitylastchangedatetime as Draftentitylastchangedatetime,
      draftadministrativedatauuid   as Draftadministrativedatauuid,
      draftentityoperationcode      as Draftentityoperationcode,
      hasactiveentity               as Hasactiveentity,
      draftfieldchanges             as Draftfieldchanges
}
