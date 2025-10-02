INTERFACE lif_bo.
  CONSTANTS: BEGIN OF cs_state_area,
               BEGIN OF order,
                 checkdates          TYPE string VALUE `checkdates`,
                 checkquantity       TYPE string VALUE `checkQuantity`,
                 checkheadercurrency TYPE string VALUE `checkHeaderCurrency`,
                 checksupplier       TYPE string VALUE `checkSupplier`,
                 checkbuyer          TYPE string VALUE `checkBuyer`,
               END OF order,
               BEGIN OF item,
                 checkquantity     TYPE string VALUE `checkquantity`,
                 checkitemcurrency TYPE string VALUE `checkItemCurrency`,
               END OF item,
             END OF cs_state_area.


  TYPES tt_calctotalamount_d       TYPE TABLE FOR DETERMINATION zob_u_r_po\\_Head~calctotalamount.
  TYPES tt_checkdates_v            TYPE TABLE FOR VALIDATION zob_u_r_po\\_Head~checkdates.
  TYPES tt_findwarehouselocation_d TYPE TABLE FOR DETERMINATION zob_u_r_po\\_Item~findwarehouselocation.
  TYPES tt_writeitemnumber_d       TYPE TABLE FOR DETERMINATION zob_u_r_po\\_Item~writeitemnumber.
  TYPES tt_calculatetotalprice_d   TYPE TABLE FOR DETERMINATION zob_u_r_po\\_Item~calculatetotalprice.


  TYPES ts_reported_late           TYPE RESPONSE FOR REPORTED LATE zob_u_r_po.
  TYPES ts_failed_late             TYPE RESPONSE FOR FAILED LATE zob_u_r_po.
  TYPES tt_order_update            TYPE TABLE FOR UPDATE zob_u_r_po\\_Head.
  TYPES tt_item_update             TYPE TABLE FOR UPDATE zob_u_r_po\\_Item.
ENDINTERFACE.

CLASS lcl_buffer DEFINITION.
  PUBLIC SECTION.
    TYPES: BEGIN OF gty_buffer,
             instance      TYPE zob_u_r_po,
             cid           TYPE string,
             newly_created TYPE abap_bool,
             changed       TYPE abap_bool,
             deleted       TYPE abap_bool,
             is_draft      TYPE abp_behv_flag,
           END OF gty_buffer.

    TYPES: BEGIN OF gty_buffer_child,
             instance   TYPE zob_u_r_po_item,
             cid_ref    TYPE string,
             cid_target TYPE string,
             changed    TYPE abap_bool,
             deleted    TYPE abap_bool,
             is_draft   TYPE abp_behv_flag,
           END OF gty_buffer_child.

    TYPES gtt_buffer       TYPE TABLE OF gty_buffer WITH EMPTY KEY.
    TYPES gtt_buffer_child TYPE TABLE OF gty_buffer_child WITH EMPTY KEY.

    CLASS-DATA root_buffer  TYPE STANDARD TABLE OF gty_buffer WITH EMPTY KEY.
    CLASS-DATA child_buffer TYPE STANDARD TABLE OF gty_buffer_child WITH EMPTY KEY.

    TYPES: BEGIN OF root_db_keys,
             purchase_order_id TYPE zpru_de_po_id,
           END OF root_db_keys.

    TYPES: BEGIN OF child_db_keys,
             purchase_order_id TYPE zpru_de_po_id,
             item_id           TYPE zpru_de_po_itm_id,
           END OF child_db_keys.

    TYPES: BEGIN OF root_keys,
             purchaseorderid TYPE Zob_I_PO-purchaseorderid,
             is_draft        TYPE abp_behv_flag,
           END OF root_keys.
    TYPES: BEGIN OF child_keys,
             purchaseorderid TYPE zob_u_r_po_item-PurchaseOrderId,
             itemid          TYPE zob_u_r_po_item-ItemId,
             is_draft        TYPE abp_behv_flag,
             full_key        TYPE abap_bool,
           END OF child_keys.
    TYPES tt_root_keys     TYPE TABLE OF root_keys WITH EMPTY KEY.
    TYPES tt_root_db_keys  TYPE TABLE OF root_db_keys WITH EMPTY KEY.
    TYPES tt_child_keys    TYPE TABLE OF child_keys WITH EMPTY KEY.
    TYPES tt_child_db_keys TYPE TABLE OF child_db_keys WITH EMPTY KEY.

    CLASS-METHODS prep_root_buffer
      IMPORTING !keys TYPE tt_root_keys.

    CLASS-METHODS prep_child_buffer
      IMPORTING !keys TYPE tt_child_keys.

ENDCLASS.


CLASS lcl_buffer IMPLEMENTATION.
  METHOD prep_root_buffer.
    DATA ls_line TYPE zob_u_r_po.

    READ ENTITIES OF zob_u_r_po
         ENTITY _Head
         ALL FIELDS WITH VALUE #( FOR <ls_drf>
                                  IN keys
                                  WHERE ( is_draft = if_abap_behv=>mk-on )
                                  ( purchaseorderid = <ls_drf>-purchaseorderid
                                    %is_draft       = <ls_drf>-is_draft  ) )
         RESULT DATA(lt_draft_buffer).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_buffer>).

      IF line_exists( lcl_buffer=>root_buffer[ instance-purchaseorderid = <ls_buffer>-purchaseorderid
                                               is_draft                 = <ls_buffer>-is_draft ] ).
        " do nothing
      ELSE.
        IF <ls_buffer>-is_draft = if_abap_behv=>mk-on.
          SELECT SINGLE @abap_true FROM @lt_draft_buffer AS draft_buffer
            WHERE purchaseorderid = @<ls_buffer>-purchaseorderid
            INTO @DATA(lv_exists_d).
          IF lv_exists_d = abap_true.
            SELECT SINGLE * FROM @lt_draft_buffer AS draft_buffer
              WHERE purchaseorderid = @<ls_buffer>-purchaseorderid
              INTO CORRESPONDING FIELDS OF @ls_line.
            IF sy-subrc = 0.
              APPEND VALUE #( instance = ls_line ) TO lcl_buffer=>root_buffer ASSIGNING FIELD-SYMBOL(<ls_just_inserted>).
              <ls_just_inserted>-is_draft = if_abap_behv=>mk-on.
            ENDIF.
          ENDIF.
        ELSE.
          SELECT SINGLE @abap_true FROM Zob_I_PO
            WHERE purchaseorderid = @<ls_buffer>-purchaseorderid
            INTO @DATA(lv_exists).
          IF lv_exists = abap_true.
            SELECT SINGLE * FROM Zob_I_PO
              WHERE purchaseorderid = @<ls_buffer>-purchaseorderid
              INTO CORRESPONDING FIELDS OF @ls_line.
            IF sy-subrc = 0.
              APPEND VALUE #( instance = ls_line ) TO lcl_buffer=>root_buffer ASSIGNING <ls_just_inserted>.
              <ls_just_inserted>-is_draft = if_abap_behv=>mk-off.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD prep_child_buffer.
    DATA lt_ch_tab  TYPE TABLE OF zob_u_r_po_item WITH EMPTY KEY.
    DATA ls_line_ch TYPE zob_u_r_po_item.

    READ ENTITIES OF zob_u_r_po
         ENTITY _Head BY \_Item
         ALL FIELDS WITH VALUE #( FOR <ls_drf>
                                  IN keys
                                  WHERE ( is_draft = if_abap_behv=>mk-on )
                                  ( purchaseorderid = <ls_drf>-purchaseorderid
                                    %is_draft       = <ls_drf>-is_draft  ) )
         RESULT DATA(lt_draft_buffer).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_buffer_ch>).

      IF <ls_buffer_ch>-full_key = abap_true.
        IF line_exists( lcl_buffer=>child_buffer[ instance-purchaseorderid = <ls_buffer_ch>-purchaseorderid
                                                  instance-itemid          = <ls_buffer_ch>-itemid
                                                  is_draft                 = <ls_buffer_ch>-is_draft ] ).
          " do nothing
        ELSE.
          IF <ls_buffer_ch>-is_draft = if_abap_behv=>mk-on.
            SELECT SINGLE @abap_true FROM @lt_draft_buffer AS draft_buffer
              WHERE purchaseorderid = @<ls_buffer_ch>-purchaseorderid
                AND itemid          = @<ls_buffer_ch>-itemid
              INTO @DATA(lv_exists_d).
            IF lv_exists_d = abap_true.

              SELECT SINGLE * FROM @lt_draft_buffer AS draft_buffer
                WHERE purchaseorderid = @<ls_buffer_ch>-purchaseorderid
                  AND itemid          = @<ls_buffer_ch>-itemid
                INTO CORRESPONDING FIELDS OF @ls_line_ch.

              IF sy-subrc = 0.
                APPEND VALUE #( instance = ls_line_ch ) TO lcl_buffer=>child_buffer ASSIGNING FIELD-SYMBOL(<ls_just_inserted>).
                <ls_just_inserted>-is_draft = if_abap_behv=>mk-on.
              ENDIF.
            ENDIF.
          ELSE.
            SELECT SINGLE @abap_true FROM Zob_I_po_item
              WHERE purchaseorderid = @<ls_buffer_ch>-purchaseorderid
                AND itemid          = @<ls_buffer_ch>-itemid
              INTO @DATA(lv_exists).
            IF lv_exists = abap_true.
              SELECT SINGLE * FROM Zob_I_po_item
                WHERE purchaseorderid = @<ls_buffer_ch>-purchaseorderid
                  AND itemid          = @<ls_buffer_ch>-itemid
                INTO CORRESPONDING FIELDS OF @ls_line_ch.

              IF sy-subrc = 0.
                APPEND VALUE #( instance = ls_line_ch ) TO lcl_buffer=>child_buffer ASSIGNING <ls_just_inserted>.
                <ls_just_inserted>-is_draft = if_abap_behv=>mk-off.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.

      ELSE.
        IF     line_exists( lcl_buffer=>root_buffer[ instance-purchaseorderid = <ls_buffer_ch>-purchaseorderid
                                                     is_draft                 = <ls_buffer_ch>-is_draft ] )
           AND VALUE #( lcl_buffer=>root_buffer[ instance-purchaseorderid = <ls_buffer_ch>-purchaseorderid
                                                 is_draft                 = <ls_buffer_ch>-is_draft ]-deleted OPTIONAL ) IS NOT INITIAL.
          " do nothing
        ELSE.
          IF <ls_buffer_ch>-is_draft = if_abap_behv=>mk-on.
            SELECT SINGLE @abap_true FROM @lt_draft_buffer AS draft_buffer
              WHERE purchaseorderid = @<ls_buffer_ch>-purchaseorderid
              INTO @DATA(lv_exists_ch_d).
            IF lv_exists_ch_d = abap_true.
              SELECT * FROM @lt_draft_buffer AS draft_buffer
                WHERE purchaseorderid = @<ls_buffer_ch>-purchaseorderid
                INTO CORRESPONDING FIELDS OF TABLE @lt_ch_tab.
              IF sy-subrc = 0.
                LOOP AT lt_ch_tab ASSIGNING FIELD-SYMBOL(<ls_ch>).
                  IF NOT line_exists( lcl_buffer=>child_buffer[ instance-purchaseorderid = <ls_ch>-purchaseorderid
                                                                instance-itemid          = <ls_ch>-itemid
                                                                is_draft                 = if_abap_behv=>mk-on ] ).
                    APPEND VALUE #( instance = <ls_ch> ) TO lcl_buffer=>child_buffer ASSIGNING <ls_just_inserted>.
                    <ls_just_inserted>-is_draft = if_abap_behv=>mk-on.
                  ENDIF.
                ENDLOOP.
              ENDIF.
            ENDIF.
          ELSE.

            SELECT SINGLE @abap_true FROM ZOB_I_PO_ITEM
              WHERE purchaseorderid = @<ls_buffer_ch>-purchaseorderid
              INTO @DATA(lv_exists_ch).
            IF lv_exists_ch = abap_true.
              SELECT * FROM ZOB_I_PO_ITEM
                WHERE purchaseorderid = @<ls_buffer_ch>-purchaseorderid
                INTO CORRESPONDING FIELDS OF TABLE @lt_ch_tab.
              IF sy-subrc = 0.
                LOOP AT lt_ch_tab ASSIGNING <ls_ch>.
                  IF NOT line_exists( lcl_buffer=>child_buffer[ instance-purchaseorderid = <ls_ch>-purchaseorderid
                                                                instance-itemid          = <ls_ch>-itemid
                                                                is_draft                 = if_abap_behv=>mk-off ] ).
                    APPEND VALUE #( instance = <ls_ch> ) TO lcl_buffer=>child_buffer ASSIGNING <ls_just_inserted>.
                    <ls_just_inserted>-is_draft = if_abap_behv=>mk-off.
                  ENDIF.
                ENDLOOP.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_det_val_manager DEFINITION INHERITING FROM cl_abap_behv FINAL CREATE PUBLIC.
  PUBLIC SECTION.




    METHODS calctotalamount_in
      IMPORTING !keys     TYPE lif_bo=>tt_calctotalamount_d
      CHANGING  !reported TYPE lif_bo=>ts_reported_late.





    METHODS checkdates_in
      IMPORTING !keys     TYPE lif_bo=>tt_checkdates_v
      CHANGING  !failed   TYPE lif_bo=>ts_failed_late
                !reported TYPE lif_bo=>ts_reported_late.





    METHODS calculatetotalprice_in
      IMPORTING !keys     TYPE lif_bo=>tt_calculatetotalprice_d
      CHANGING  !reported TYPE lif_bo=>ts_reported_late.

    METHODS findwarehouselocation_in
      IMPORTING !keys     TYPE lif_bo=>tt_findwarehouselocation_d
      CHANGING  !reported TYPE lif_bo=>ts_reported_late.

    METHODS writeitemnumber_in
      IMPORTING !keys     TYPE lif_bo=>tt_writeitemnumber_d
      CHANGING  !reported TYPE lif_bo=>ts_reported_late.




ENDCLASS.

CLASS lcl_det_val_manager IMPLEMENTATION.




  METHOD writeitemnumber_in.
    DATA lt_item_update    TYPE TABLE FOR UPDATE zob_u_r_po\\_Item.
    DATA lt_existing_items TYPE TABLE FOR READ RESULT zob_u_r_po\\_Item.

    IF keys IS INITIAL.
      APPEND INITIAL LINE TO reported-%other ASSIGNING FIELD-SYMBOL(<lo_reported>).
      <lo_reported> = new_message( id       = zob_if_m_po=>gc_po_message_class
                                   number   = '001'
                                   severity = if_abap_behv_message=>severity-error ).
      RETURN.
    ENDIF.

    READ ENTITIES OF zob_u_r_po
         IN LOCAL MODE
         ENTITY _Item
         ALL FIELDS
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_items).

    IF lt_items IS INITIAL.
      APPEND INITIAL LINE TO reported-%other ASSIGNING <lo_reported>.
      <lo_reported> = new_message( id       = zob_if_m_po=>gc_po_message_class
                                   number   = '002'
                                   severity = if_abap_behv_message=>severity-error ).
      RETURN.
    ENDIF.

    READ ENTITIES OF zob_u_r_po
         IN LOCAL MODE
         ENTITY _Item BY \_Head
         ALL FIELDS
         WITH VALUE #( FOR <ls_i> IN keys
                       ( %tky-%is_draft       = <ls_i>-%is_draft
                         %tky-purchaseorderid = <ls_i>-purchaseorderid
                         %tky-itemid          = <ls_i>-itemid  ) )
         LINK DATA(lt_item_to_order).

    READ ENTITIES OF zob_u_r_po
         IN LOCAL MODE
         ENTITY _Head BY \_Item
         ALL FIELDS
         WITH VALUE #( FOR <ls_ord> IN lt_item_to_order
                       ( CORRESPONDING #( <ls_ord>-target ) ) )
         RESULT DATA(lt_all_items).

    LOOP AT lt_items ASSIGNING FIELD-SYMBOL(<ls_group>)
         GROUP BY ( is_draft        = <ls_group>-%is_draft
                    purchaseorderid = <ls_group>-purchaseorderid ) ASSIGNING FIELD-SYMBOL(<ls_group_key>).

      LOOP AT lt_all_items ASSIGNING FIELD-SYMBOL(<ls_all_items>).
        IF line_exists( keys[ KEY id COMPONENTS %tky = <ls_all_items>-%tky ] ).
          CONTINUE.
        ENDIF.
        APPEND INITIAL LINE TO lt_existing_items ASSIGNING FIELD-SYMBOL(<ls_existing_item>).
        <ls_existing_item> = CORRESPONDING #( <ls_all_items> ).
      ENDLOOP.

      SORT lt_existing_items BY itemnumber DESCENDING.
      DATA(lv_count) = COND i( WHEN lines( lt_existing_items ) > 0
                               THEN VALUE #( lt_existing_items[ 1 ]-itemnumber OPTIONAL )
                               ELSE 0 ).

      LOOP AT GROUP <ls_group_key> ASSIGNING FIELD-SYMBOL(<ls_member>).

        lv_count = lv_count + 1.
        APPEND INITIAL LINE TO lt_item_update ASSIGNING FIELD-SYMBOL(<ls_item_update>).
        <ls_item_update>-%tky = <ls_member>-%tky.
        <ls_item_update>-%data-itemnumber = lv_count.
        <ls_item_update>-%control-itemnumber = if_abap_behv=>mk-on.
      ENDLOOP.

    ENDLOOP.

    IF lt_item_update IS INITIAL.
      RETURN.
    ENDIF.

    MODIFY ENTITIES OF zob_u_r_po
           IN LOCAL MODE
           ENTITY _Item
           UPDATE FROM lt_item_update.
  ENDMETHOD.

  METHOD findwarehouselocation_in.
  ENDMETHOD.

  METHOD calculatetotalprice_in.
    DATA lt_item_update TYPE TABLE FOR UPDATE zob_u_r_po\\_Item.

    IF keys IS INITIAL.
      APPEND INITIAL LINE TO reported-%other ASSIGNING FIELD-SYMBOL(<lo_reported>).
      <lo_reported> = new_message( id       = zob_if_m_po=>gc_po_message_class
                                   number   = '001'
                                   severity = if_abap_behv_message=>severity-error ).
      RETURN.
    ENDIF.

    READ ENTITIES OF zob_u_r_po
         IN LOCAL MODE
         ENTITY _Item
         FIELDS ( quantity
                  unitprice )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_items).

    IF lt_items IS INITIAL.
      APPEND INITIAL LINE TO reported-%other ASSIGNING <lo_reported>.
      <lo_reported> = new_message( id       = zob_if_m_po=>gc_po_message_class
                                   number   = '002'
                                   severity = if_abap_behv_message=>severity-error ).
      RETURN.
    ENDIF.

    LOOP AT lt_items ASSIGNING FIELD-SYMBOL(<ls_instance>).

      APPEND INITIAL LINE TO lt_item_update ASSIGNING FIELD-SYMBOL(<ls_item_update>).
      <ls_item_update>-%tky = <ls_instance>-%tky.
      <ls_item_update>-%data-totalprice = <ls_instance>-quantity * <ls_instance>-unitprice.
      <ls_item_update>-%control-totalprice = if_abap_behv=>mk-on.

    ENDLOOP.

    IF lt_item_update IS INITIAL.
      RETURN.
    ENDIF.

    MODIFY ENTITIES OF zob_u_r_po
           IN LOCAL MODE
           ENTITY _Item
           UPDATE FROM lt_item_update.
  ENDMETHOD.








  METHOD calctotalamount_in.
    DATA lt_order_update     TYPE TABLE FOR UPDATE zob_u_r_po\\_Head.
    DATA lv_new_total_amount TYPE zob_u_r_po-totalamount.

    IF keys IS INITIAL.
      APPEND INITIAL LINE TO reported-%other ASSIGNING FIELD-SYMBOL(<lo_reported>).
      <lo_reported> = new_message( id       = zob_if_m_po=>gc_po_message_class
                                   number   = '001'
                                   severity = if_abap_behv_message=>severity-error ).
      RETURN.
    ENDIF.

    READ ENTITIES OF zob_u_r_po
         IN LOCAL MODE
         ENTITY _Head
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(lt_roots).

    IF lt_roots IS INITIAL.
      APPEND INITIAL LINE TO reported-%other ASSIGNING <lo_reported>.
      <lo_reported> = new_message( id       = zob_if_m_po=>gc_po_message_class
                                   number   = '002'
                                   severity = if_abap_behv_message=>severity-error ).
      RETURN.
    ENDIF.

    READ ENTITIES OF zob_u_r_po
         IN LOCAL MODE
         ENTITY _Head BY \_Item
         ALL FIELDS WITH CORRESPONDING #( lt_roots )
         RESULT DATA(lt_items).

    LOOP AT lt_roots ASSIGNING FIELD-SYMBOL(<ls_instance>).

      CLEAR lv_new_total_amount.
      LOOP AT lt_items ASSIGNING FIELD-SYMBOL(<ls_item>)
           WHERE purchaseorderid = <ls_instance>-purchaseorderid.
        lv_new_total_amount = lv_new_total_amount + <ls_item>-%data-totalprice.
      ENDLOOP.
      " prevent auto triggering
      IF <ls_instance>-totalamount <> lv_new_total_amount.
        APPEND INITIAL LINE TO lt_order_update ASSIGNING FIELD-SYMBOL(<ls_order_update>).
        <ls_order_update>-%tky        = <ls_instance>-%tky.
        <ls_order_update>-totalamount = lv_new_total_amount.
        <ls_order_update>-%control-totalamount = if_abap_behv=>mk-on.
      ENDIF.

    ENDLOOP.

    IF lt_order_update IS INITIAL.
      RETURN.
    ENDIF.

    MODIFY ENTITIES OF zob_u_r_po
           IN LOCAL MODE
           ENTITY _Head
           UPDATE FROM lt_order_update.
  ENDMETHOD.

  METHOD checkdates_in.
    IF keys IS INITIAL.
      APPEND INITIAL LINE TO reported-%other ASSIGNING FIELD-SYMBOL(<lo_reported>).
      <lo_reported> = new_message( id       = zob_if_m_po=>gc_po_message_class
                                   number   = '001'
                                   severity = if_abap_behv_message=>severity-error ).
      RETURN.
    ENDIF.

    READ ENTITIES OF zob_u_r_po
         IN LOCAL MODE
         ENTITY _Head
         FIELDS ( orderdate deliverydate )
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
        APPEND INITIAL LINE TO failed-_head ASSIGNING FIELD-SYMBOL(<ls_failed>).
        <ls_failed>-%tky = <ls_instance>-%tky.
        <ls_failed>-%fail-cause = if_abap_behv=>cause-not_found.
        CONTINUE.
      ENDIF.

      APPEND INITIAL LINE TO reported-_head ASSIGNING FIELD-SYMBOL(<ls_order_reported>).
      <ls_order_reported>-%tky        = <ls_instance>-%tky.
      <ls_order_reported>-%state_area = lif_bo=>cs_state_area-order-checkdates.

      IF <ls_instance>-OrderDate > <ls_instance>-DeliveryDate.
        APPEND INITIAL LINE TO failed-_head ASSIGNING <ls_failed>.
        <ls_failed>-%tky = <ls_instance>-%tky.

        APPEND INITIAL LINE TO reported-_head ASSIGNING <ls_order_reported>.
        <ls_order_reported>-%tky        = <ls_instance>-%tky.
        <ls_order_reported>-%state_area = lif_bo=>cs_state_area-order-checkdates.
        <ls_order_reported>-%msg        = new_message( id       = zob_if_m_po=>gc_po_message_class
                                                       number   = '003'
                                                       severity = if_abap_behv_message=>severity-error ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.


CLASS lhc__Head DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR _Head RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE _Head.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE _Head.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE _Head.

    METHODS read FOR READ
      IMPORTING keys FOR READ _Head RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK _Head.

    METHODS rba_Item FOR READ
      IMPORTING keys_rba FOR READ _Head\_Item FULL result_requested RESULT result LINK association_links.

    METHODS cba_Item FOR MODIFY
      IMPORTING entities_cba FOR CREATE _Head\_Item.

ENDCLASS.

CLASS lhc__Head IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD create.
  ENDMETHOD.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD rba_Item.
  ENDMETHOD.

  METHOD cba_Item.
  ENDMETHOD.

ENDCLASS.

CLASS lhc__Item DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE _Item.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE _Item.

    METHODS read FOR READ
      IMPORTING keys FOR READ _Item RESULT result.

    METHODS rba_Head FOR READ
      IMPORTING keys_rba FOR READ _Item\_Head FULL result_requested RESULT result LINK association_links.
    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR _Item~calculateTotalPrice.

    METHODS findWarehouseLocation FOR DETERMINE ON SAVE
      IMPORTING keys FOR _Item~findWarehouseLocation.

    METHODS writeItemNumber FOR DETERMINE ON SAVE
      IMPORTING keys FOR _Item~writeItemNumber.




ENDCLASS.

CLASS lhc__Item IMPLEMENTATION.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD rba_Head.
  ENDMETHOD.

  METHOD calculateTotalPrice.
  NEW lcl_det_val_manager( )->calculatetotalprice_in( EXPORTING keys     = keys
                                                        CHANGING  reported = reported ).
  ENDMETHOD.

  METHOD findWarehouseLocation.
  NEW lcl_det_val_manager( )->findwarehouselocation_in( EXPORTING keys     = keys
                                                          CHANGING  reported = reported ).
  ENDMETHOD.

  METHOD writeItemNumber.
  NEW lcl_det_val_manager( )->writeitemnumber_in( EXPORTING keys     = keys
                                                    CHANGING  reported = reported ).
  ENDMETHOD.


ENDCLASS.

CLASS lsc_ZOB_U_R_PO DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZOB_U_R_PO IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
