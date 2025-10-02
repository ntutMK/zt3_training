@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Consumption view for Purchase Order Item'

@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true

@VDM.viewType: #CONSUMPTION

define view entity ZOB_U_C_PO_ITEM
  as projection on ZOB_U_R_Po_Item

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

      /* Associations */
      _Head: redirected to parent ZOB_U_C_PO
}
