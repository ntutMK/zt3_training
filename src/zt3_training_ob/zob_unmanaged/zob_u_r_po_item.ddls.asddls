@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Trasactional View For Purchase Order Itm'

@Metadata.ignorePropagatedAnnotations: true

@VDM.viewType: #TRANSACTIONAL

define view entity ZOB_U_R_PO_ITEM
  as select from Zob_I_po_item

  association to parent ZOB_U_R_PO as _Head on $projection.PurchaseOrderId = _Head.PurchaseOrderId

{
  key ItemId,
  key PurchaseOrderId,

      ItemNumber,
      ProductId,
      ProductName,
      Quantity,

      @Semantics.amount.currencyCode: 'ItemCurrency'
      UnitPrice,

      @Semantics.amount.currencyCode: 'ItemCurrency'
      TotalPrice,

      DeliveryDate,
      WarehouseLocation,
      ItemCurrency,
      IsUrgent,
      @Semantics.user.createdBy: true
      CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      CreateOn,
      @Semantics.user.localInstanceLastChangedBy: true
      ChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      ChangedOn,
      

      _Head
}
