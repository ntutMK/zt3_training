INTERFACE lif_bo.
  TYPES tt_order_update TYPE TABLE FOR UPDATE zob_r_po\\_Header.
  TYPES tt_item_update  TYPE TABLE FOR UPDATE zob_r_po\\_Item.
ENDINTERFACE.
CLASS lhc__item DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR _Item~calculateTotalPrice.
    METHODS writeItemNumber FOR DETERMINE ON SAVE
      IMPORTING keys FOR _Item~writeItemNumber.

ENDCLASS.

CLASS lhc__item IMPLEMENTATION.
  METHOD calculateTotalPrice.
    DATA lt_item_update TYPE lif_bo=>tt_item_update.

    IF keys IS INITIAL.
      APPEND INITIAL LINE TO reported-%other ASSIGNING FIELD-SYMBOL(<lo_reported>).
      <lo_reported> = new_message( id       = zpru_if_m_po=>gc_po_message_class
                                   number   = '001'
                                   severity = if_abap_behv_message=>severity-error ).
      RETURN.
    ENDIF.

    READ ENTITIES OF zob_r_po
         IN LOCAL MODE
         ENTITY _Item
         FIELDS ( quantity
                  unitprice )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_items).

    IF lt_items IS INITIAL.
      APPEND INITIAL LINE TO reported-%other ASSIGNING <lo_reported>.
      <lo_reported> = new_message( id       = zpru_if_m_po=>gc_po_message_class
                                   number   = '002'
                                   severity = if_abap_behv_message=>severity-error ).
      RETURN.
    ENDIF.

    LOOP AT lt_items ASSIGNING FIELD-SYMBOL(<ls_instance>).

      APPEND INITIAL LINE TO lt_item_update ASSIGNING FIELD-SYMBOL(<ls_item_update>).
      <ls_item_update>-%tky = <ls_instance>-%tky.
      <ls_item_update>-%data-totalPrice = <ls_instance>-quantity * <ls_instance>-unitprice.
      <ls_item_update>-%control-totalPrice = if_abap_behv=>mk-on.

    ENDLOOP.

    IF lt_item_update IS INITIAL.
      RETURN.
    ENDIF.

    MODIFY ENTITIES OF zob_r_po
           IN LOCAL MODE
           ENTITY _Item
           UPDATE FROM lt_item_update.
  ENDMETHOD.

  METHOD writeItemNumber.
    DATA lt_item_update    TYPE lif_bo=>tt_item_update.
    DATA lt_EXISTING_items TYPE TABLE FOR READ RESULT zob_r_po\\_Item.

    IF keys IS INITIAL.
      APPEND INITIAL LINE TO reported-%other ASSIGNING FIELD-SYMBOL(<lo_reported>).
      <lo_reported> = new_message( id       = zpru_if_m_po=>gc_po_message_class
                                   number   = '001'
                                   severity = if_abap_behv_message=>severity-error ).
      RETURN.
    ENDIF.

    READ ENTITIES OF zob_r_po
         IN LOCAL MODE
         ENTITY _Item
         ALL FIELDS
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_items).

    IF lt_items IS INITIAL.
      APPEND INITIAL LINE TO reported-%other ASSIGNING <lo_reported>.
      <lo_reported> = new_message( id       = zpru_if_m_po=>gc_po_message_class
                                   number   = '002'
                                   severity = if_abap_behv_message=>severity-error ).
      RETURN.
    ENDIF.

    READ ENTITIES OF zob_r_po
         IN LOCAL MODE
         ENTITY _Item BY \_Head
         ALL FIELDS
         WITH VALUE #( FOR <ls_i> IN keys
                       ( %tky-%pid            = <ls_i>-%pid
                         %tky-purchaseOrderId = <ls_i>-purchaseOrderId
                         %tky-itemId          = <ls_i>-itemId  ) )
         LINK DATA(lt_item_to_order).

    READ ENTITIES OF zob_r_po
         IN LOCAL MODE
         ENTITY _Header BY \_Item
         ALL FIELDS
         WITH VALUE #( FOR <ls_ord> IN lt_item_to_order
                       ( CORRESPONDING #( <ls_ord>-target ) ) )
         RESULT DATA(lt_ALL_items).

    LOOP AT lt_items ASSIGNING FIELD-SYMBOL(<ls_GROUP>)
         GROUP BY ( pidparent       = <ls_GROUP>-%pidparent
                    purchaseorderid = <ls_GROUP>-purchaseorderid ) ASSIGNING FIELD-SYMBOL(<ls_GROUP_key>).

      LOOP AT lt_ALL_items ASSIGNING FIELD-SYMBOL(<ls_ALL_ITEMS>).
        IF line_exists( keys[ KEY id COMPONENTS %tky = <ls_ALL_ITEMS>-%tky ] ).
          CONTINUE.
        ENDIF.
        APPEND INITIAL LINE TO lt_EXISTING_items ASSIGNING FIELD-SYMBOL(<ls_existing_item>).
        <ls_existing_item> = CORRESPONDING #( <ls_ALL_ITEMS> ).
      ENDLOOP.

      SORT lt_EXISTING_items BY itemNumber DESCENDING.
      DATA(lv_count) = COND i( WHEN lines( lt_EXISTING_items ) > 0
                               THEN VALUE #( lt_EXISTING_items[ 1 ]-itemNumber OPTIONAL )
                               ELSE 0 ).

      LOOP AT GROUP <ls_GROUP_key> ASSIGNING FIELD-SYMBOL(<ls_MEMBER>).

        lv_count = lv_count + 1.
        APPEND INITIAL LINE TO lt_item_update ASSIGNING FIELD-SYMBOL(<ls_item_update>).
        <ls_item_update>-%tky = <ls_member>-%tky.
        <ls_item_update>-%data-itemNumber = lv_count.
        <ls_item_update>-%control-itemNumber = if_abap_behv=>mk-on.
      ENDLOOP.

    ENDLOOP.

    IF lt_item_update IS INITIAL.
      RETURN.
    ENDIF.

    MODIFY ENTITIES OF ZOB_R_PO
           IN LOCAL MODE
           ENTITY _Item
           UPDATE FROM lt_item_update.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zob_r_po DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS adjust_numbers REDEFINITION.

ENDCLASS.

CLASS lsc_zob_r_po IMPLEMENTATION.
  METHOD adjust_numbers.
    IF mapped IS INITIAL.
      RETURN.
    ENDIF.
    IF mapped-_header IS NOT INITIAL.
      DATA(lv_last_po) = zob_cl_po=>get_last_po_number( ).
      LOOP AT mapped-_header ASSIGNING FIELD-SYMBOL(<ls_order>).
        lv_last_po = lv_last_po + 1.
        DATA(lv_lastpo_c) = conv zpru_de_po_id( lv_last_po ).
        lv_lastpo_c = |{ lv_lastpo_c ALPHA = IN }|.
        <ls_order>-%key-purchaseOrderId = lv_last_po.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_ZOB_R_PO DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zob_r_po RESULT result.
    METHODS changestatus FOR MODIFY
      IMPORTING keys FOR ACTION _header~changestatus.

    METHODS precheck_changestatus FOR PRECHECK
      IMPORTING keys FOR ACTION _header~changestatus.
    METHODS checkdates FOR VALIDATE ON SAVE
      IMPORTING keys FOR _header~checkdates.
    METHODS calctotalamount FOR DETERMINE ON SAVE
      IMPORTING keys FOR _header~calctotalamount.

ENDCLASS.

CLASS lhc_ZOB_R_PO IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD ChangeStatus.
    DATA lt_po_update TYPE lif_bo=>tt_order_update.

    IF keys IS INITIAL.
      APPEND INITIAL LINE TO reported-%other ASSIGNING FIELD-SYMBOL(<lo_reported>).
      <lo_reported> = new_message( id       = zob_if_m_po=>gc_po_message_class
                                   number   = '001'
                                   severity = if_abap_behv_message=>severity-error ).
      RETURN.
    ENDIF.

    READ ENTITIES OF zob_r_po
         IN LOCAL MODE
         ENTITY _Header
         ALL FIELDS
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_roots).

    IF lt_roots IS INITIAL.
      APPEND INITIAL LINE TO reported-%other ASSIGNING <lo_reported>.
      <lo_reported> = new_message( id       = zob_if_m_po=>gc_po_message_class
                                   number   = '002'
                                   severity = if_abap_behv_message=>severity-error ).
      RETURN.
    ENDIF.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).

      ASSIGN lt_roots[ KEY id COMPONENTS %tky = <ls_key>-%tky ] TO FIELD-SYMBOL(<ls_instance>).
      IF sy-subrc <> 0.
        APPEND INITIAL LINE TO failed-_header ASSIGNING FIELD-SYMBOL(<ls_failed>).
        <ls_failed>-%tky = <ls_instance>-%tky.
        <ls_failed>-%fail-cause = if_abap_behv=>cause-not_found.
        <ls_failed>-%action-ChangeStatus = if_abap_behv=>mk-on.
        CONTINUE.
      ENDIF.

      APPEND INITIAL LINE TO lt_po_update ASSIGNING FIELD-SYMBOL(<ls_order_update>).
      <ls_order_update>-%tky = <ls_instance>-%tky.
      <ls_order_update>-%data-Status = <ls_key>-%param-newstatus.
      <ls_order_update>-%control-Status = if_abap_behv=>mk-on.

    ENDLOOP.

    " update status
    IF lt_po_update IS NOT INITIAL.
      MODIFY ENTITIES OF zob_r_po
             IN LOCAL MODE
             ENTITY _Header
             UPDATE FROM lt_po_update.
    ENDIF.
  ENDMETHOD.

  METHOD precheck_ChangeStatus.
  ENDMETHOD.

  METHOD checkDates.
    IF keys IS INITIAL.
      APPEND INITIAL LINE TO reported-%other ASSIGNING FIELD-SYMBOL(<lo_reported>).
      <lo_reported> = new_message( id       = zpru_if_m_po=>gc_po_message_class
                                   number   = '001'
                                   severity = if_abap_behv_message=>severity-error ).
      RETURN.
    ENDIF.

    READ ENTITIES OF zob_r_po
         IN LOCAL MODE
         ENTITY _Header
         FIELDS ( OrderDate DeliveryDate )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_roots).

    IF lt_roots IS INITIAL.
      APPEND INITIAL LINE TO reported-%other ASSIGNING <lo_reported>.
      <lo_reported> = new_message( id       = zob_if_m_po=>gc_po_message_class
                                   number   = '002'
                                   severity = if_abap_behv_message=>severity-error ).
      RETURN.
    ENDIF.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).

      ASSIGN lt_roots[ KEY id COMPONENTS %tky = <ls_key>-%tky ] TO FIELD-SYMBOL(<ls_instance>).
      IF sy-subrc <> 0.
        APPEND INITIAL LINE TO failed-_header ASSIGNING FIELD-SYMBOL(<ls_failed>).
        <ls_failed>-%tky = <ls_instance>-%tky.
        <ls_failed>-%fail-cause = if_abap_behv=>cause-not_found.
        CONTINUE.
      ENDIF.

      APPEND INITIAL LINE TO reported-_header ASSIGNING FIELD-SYMBOL(<ls_order_reported>).
      <ls_order_reported>-%tky        = <ls_instance>-%tky.
      <ls_order_reported>-%state_area = 'checkdates'.

      IF <ls_instance>-orderDate > <ls_instance>-DeliveryDate.
        APPEND INITIAL LINE TO failed-_header ASSIGNING <ls_failed>.
        <ls_failed>-%tky = <ls_instance>-%tky.

        APPEND INITIAL LINE TO reported-_header ASSIGNING <ls_order_reported>.
        <ls_order_reported>-%tky        = <ls_instance>-%tky.
        <ls_order_reported>-%state_area = 'checkdates'.
        <ls_order_reported>-%msg        = new_message( id       = zob_if_m_po=>gc_po_message_class
                                                       number   = '003'
                                                       severity = if_abap_behv_message=>severity-error ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD calcTotalAmount.
    DATA lt_order_update     TYPE lif_bo=>tt_order_update.
    DATA lv_new_total_amount TYPE ZOB_R_PO-TotalAmount.

    IF keys IS INITIAL.
      APPEND INITIAL LINE TO reported-%other ASSIGNING FIELD-SYMBOL(<lo_reported>).
      <lo_reported> = new_message( id       = zob_if_m_po=>gc_po_message_class
                                   number   = '001'
                                   severity = if_abap_behv_message=>severity-error ).
      RETURN.
    ENDIF.

    READ ENTITIES OF zob_r_po
         IN LOCAL MODE
         ENTITY _Header
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(lt_roots).

    IF lt_roots IS INITIAL.
      APPEND INITIAL LINE TO reported-%other ASSIGNING <lo_reported>.
      <lo_reported> = new_message( id       = zob_if_m_po=>gc_po_message_class
                                   number   = '002'
                                   severity = if_abap_behv_message=>severity-error ).
      RETURN.
    ENDIF.

    READ ENTITIES OF zob_r_po
         IN LOCAL MODE
         ENTITY _Header BY \_Item
         ALL FIELDS WITH CORRESPONDING #( lt_roots )
         RESULT DATA(lt_items).

    LOOP AT lt_roots ASSIGNING FIELD-SYMBOL(<ls_instance>).

      CLEAR lv_new_total_amount.
      LOOP AT lt_items ASSIGNING FIELD-SYMBOL(<ls_item>) WHERE %pidparent = <ls_instance>-%pid.
        lv_new_total_amount = lv_new_total_amount + <ls_item>-%data-totalPrice.
      ENDLOOP.
      " prevent auto triggering
      IF <ls_instance>-totalAmount <> lv_new_total_amount.
        APPEND INITIAL LINE TO lt_order_update ASSIGNING FIELD-SYMBOL(<ls_order_update>).
        <ls_order_update>-%tky        = <ls_instance>-%tky.
        <ls_order_update>-totalAmount = lv_new_total_amount.
        <ls_order_update>-%control-totalAmount = if_abap_behv=>mk-on.
      ENDIF.

    ENDLOOP.

    IF lt_order_update IS INITIAL.
      RETURN.
    ENDIF.

    MODIFY ENTITIES OF zob_r_po
           IN LOCAL MODE
           ENTITY _Header
           UPDATE FROM lt_order_update.
  ENDMETHOD.

ENDCLASS.
