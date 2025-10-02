@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Basic View Entity for Purchase Item'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZACH_I_PURCITEM 
    as select from zach_po_item
    
{
    key item_id as ItemId,
    key purchase_order_id as PurchaseOrderId,
    item_number as ItemNumber,
    product_id as ProductId,
    product_name as ProductName,
    quantity as Quantity,
    @Semantics.amount.currencyCode : 'ItemCurrency'
    unit_price as UnitPrice,
    @Semantics.amount.currencyCode : 'ItemCurrency'
    total_price as TotalPrice,
    delivery_date as DeliveryDate,
    warehouse_location as WarehouseLocation,
    item_currency as ItemCurrency,
    is_urgent as IsUrgent,
    created_by as CreatedBy,
    create_on as CreateOn,
    changed_by as ChangedBy,
    changed_on as ChangedOn
}
