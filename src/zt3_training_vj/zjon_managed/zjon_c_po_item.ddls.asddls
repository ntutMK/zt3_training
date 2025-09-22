@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption Purchase Order Item'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@VDM.viewType: #CONSUMPTION
define view entity ZJON_C_PO_ITEM
  provider contract transactional_query
  as projection on ZJON_R_PO_ITEM_TP as Item
{
  key ItemId,
  key PurchaseOrderId,
      ItemNumber,
      ProductId,
      ProductName,
      Quantity,
      @Semantics.amount.currencyCode : 'ItemCurrency'
      UnitPrice,
      @Semantics.amount.currencyCode : 'ItemCurrency'
      TotalPrice,
      DeliveryDate,
      WarehouseLocation,
      ItemCurrency,
      IsUrgent,
      CreatedBy,
      CreateOn,
      ChangedBy,
      ChangedOn,
      /* Associations */
      _header
}
