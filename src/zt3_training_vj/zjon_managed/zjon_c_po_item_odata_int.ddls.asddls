@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption view for PO Item'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZJON_C_PO_ITEM_ODATA_INT
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
    _header : redirected to parent ZJON_C_PURC_ORDER_ODATA_INT
}
