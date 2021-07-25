REPORT  Z_PROJECT.

data ok_code type sy-ucomm.

call screen 9090.

************* 9090  **********************
data: ROLEINPUT type string,
      L_USERNAME type string,
      L_PASSWORD type string.
******************************************

************* 9092  **********************
data: SELLER_USERNAME type string.
******************************************

************* 9093  **********************
data: BUYER_USERNAME type string.
******************************************

module STATUS_9090 output.
  SET PF-STATUS 'ZSTATUS'.
  SET TITLEBAR 'ZTITLE'.
endmodule.

module USER_COMMAND_9090 input.
  data:result type Z_BOOL.

  data obj_db_op type ref to Z_DB_OPERATOR.
      create object obj_db_op.

  case ok_code.
    when 'BACK'.
      leave to screen 0.
    when 'REGISTERBTN'.
      result = Z_VALIDATE=>ALL( input_role = ROLEINPUT
                                input_username = L_USERNAME
                                input_password = L_PASSWORD ).
      if result = 'F'.
        return.
      endif.

      if ROLEINPUT = 'SELLER'.
        data obj_seller type ref to Z_SELLER.
        create object obj_seller exporting  INPUT_ROLE = ROLEINPUT
                                            INPUT_USERNAME = L_USERNAME
                                            INPUT_PASSWORD = L_PASSWORD.

        result = obj_db_op->CREATE_SELLER( obj_seller ).

        Z_RESULT_INFO=>message( INPUT_RESULT = result INPUT_MESSAGE = 'Registration' ).

      elseif ROLEINPUT = 'BUYER'.
        data obj_buyer type ref to Z_BUYER.
        create object obj_buyer exporting   INPUT_ROLE = ROLEINPUT
                                            INPUT_USERNAME = L_USERNAME
                                            INPUT_PASSWORD = L_PASSWORD.

        result = obj_db_op->CREATE_BUYER( obj_buyer ).

        Z_RESULT_INFO=>message( INPUT_RESULT = result INPUT_MESSAGE = 'Registration' ).

      endif.

    when 'LOGINBTN'.
      result = Z_VALIDATE=>ALL( input_role = ROLEINPUT
                                input_username = L_USERNAME
                                input_password = L_PASSWORD ).
      if result = 'F'.
        return.
      endif.

      data obj_user type ref to Z_USER.
        create object obj_user exporting   INPUT_ROLE = ROLEINPUT
                                           INPUT_USERNAME = L_USERNAME
                                           INPUT_PASSWORD = L_PASSWORD.

      result = obj_db_op->CHECK_USER( INPUT_USER = obj_user ).

      Z_RESULT_INFO=>message( INPUT_RESULT = result INPUT_MESSAGE = 'Login' ).

      if result = 'T'.
        if ROLEINPUT = 'SELLER'.
          SELLER_USERNAME = L_USERNAME.
          call screen 9092.
        elseif ROLEINPUT = 'BUYER'.
          BUYER_USERNAME = L_USERNAME.
          call screen 9093.
        endif.
      endif.

    when others.
      message ok_code type 'I'.
  endcase.
endmodule.

module STATUS_9092 output.
  SET PF-STATUS 'ZSTATUS2'.
  SET TITLEBAR 'ZTITLE2'.

  data: ls_t type table of ZTB_ONSALE,
        row TYPE ZTB_ONSALE,
        go_grid type ref to cl_gui_alv_grid,
        go_customer_container type ref to cl_gui_custom_container,

        lt_fcat TYPE lvc_t_fcat,
        ls_fcat TYPE lvc_s_fcat.

  select * from ZTB_ONSALE into table ls_t where owner = SELLER_USERNAME.

  sort ls_t by id ASCENDING.

  REFRESH lt_fcat.
  DATA: lv_pos TYPE i.
  lv_pos = lv_pos + 1.
  ls_fcat-fieldname = 'ID'.
  ls_fcat-coltext = 'ID'.
  ls_fcat-col_pos = lv_pos.
  ls_fcat-outputlen = 3.
  APPEND ls_fcat TO lt_fcat.
  lv_pos = lv_pos + 1.
  ls_fcat-fieldname = 'NAME'.
  ls_fcat-coltext = 'Item Name'.
  ls_fcat-col_pos = lv_pos.
  ls_fcat-outputlen = 10.
  APPEND ls_fcat TO lt_fcat.
  lv_pos = lv_pos + 1.
  ls_fcat-fieldname = 'PRICE'.
  ls_fcat-coltext = 'Item Price'.
  ls_fcat-col_pos = lv_pos.
  ls_fcat-outputlen = 20.
  APPEND ls_fcat TO lt_fcat.
  lv_pos = lv_pos + 1.
  ls_fcat-fieldname = 'QUANTITY'.
  ls_fcat-coltext = 'Item Quantity'.
  ls_fcat-col_pos = lv_pos.
  ls_fcat-outputlen = 20.
  APPEND ls_fcat TO lt_fcat.
  lv_pos = lv_pos + 1.
  ls_fcat-fieldname = 'OWNER'.
  ls_fcat-coltext = 'Item owner'.
  ls_fcat-col_pos = lv_pos.
  ls_fcat-outputlen = 20.
  APPEND ls_fcat TO lt_fcat.



  if go_customer_container is initial.
    create object go_customer_container
      exporting
        container_name = 'TABLE_ADDED_ITEM'.
    create object go_grid
      exporting
        i_parent = go_customer_container.
  endif.

  call method go_grid->set_table_for_first_display
    CHANGING
        it_outtab       = ls_t
        it_fieldcatalog = lt_fcat.

endmodule.

data : ITEM_NAME type string,
       ITEM_PRICE type string,
       ITEM_QUANTITY type string.

module USER_COMMAND_9092 input.
data obj_onsale type ref to Z_ONSALE.
        create object obj_onsale exporting  input_name = ITEM_NAME
                                            input_price = ITEM_PRICE
                                            input_quantity = ITEM_QUANTITY
                                            input_owner = SELLER_USERNAME.
 case ok_code.
    when 'BACK'.
      leave to screen 0.
    when 'ADDBTN'.
      result = Z_VALIDATE=>ALL_SELLER( INPUT_ONSALE = obj_onsale ).

      if result = 'F'.
        return.
      endif.

      result = obj_db_op->CREATE_ONSALE( INPUT_ONSALE = obj_onsale ).

      Z_RESULT_INFO=>message( INPUT_RESULT = result INPUT_MESSAGE = 'Add Item' ).

    when 'DELETEBTN'.
      result = Z_VALIDATE=>SELLER_ONSALE_NAME( INPUT_ONSALE = obj_onsale ).

      if result = 'F'.
        return.
      endif.

      result = obj_db_op->DELETE_ONSALE( INPUT_ONSALE = obj_onsale ).

      Z_RESULT_INFO=>message( INPUT_RESULT = result INPUT_MESSAGE = 'Delete Item' ).

    when others.
      message ok_code type 'I'.
      leave to screen 0.
  endcase.
endmodule.

module STATUS_9093 output.
  SET PF-STATUS 'ZSTATUS3'.
  SET TITLEBAR 'ZTITLE3'.

  data: ls_t_1 type table of ZTB_ONSALE,
      row_1 TYPE ZTB_ONSALE,
      go_grid_1 type ref to cl_gui_alv_grid,
      go_customer_container_1 type ref to cl_gui_custom_container,

      lt_fcat_1 TYPE lvc_t_fcat,
      ls_fcat_1 TYPE lvc_s_fcat.

  select * from ZTB_ONSALE into table ls_t_1.

  sort ls_t_1 by id ASCENDING.
**********************  could pack it into a method but *******
*  DATA: it_onsale TYPE STANDARD TABLE OF ZTB_ONSALE,
*      wa_onsale type ZTB_ONSALE.

DATA: it_item TYPE STANDARD TABLE OF ZTB_ITEM,
      wa_item type ZTB_ITEM.

SELECT * FROM ZTB_ONSALE INTO TABLE ls_t_1.

data: eprice type Z_STRING,
      tmp_f type f,
      tmp_s type Z_STRING,
      tmp_len type int4.

data arr type ref to Z_ARRAY_F.
create object arr.

LOOP AT ls_t_1 into row_1.
  SELECT * FROM ZTB_ITEM INTO TABLE it_item where oid = row_1-id.

  if sy-subrc = 0.
    LOOP AT it_item into wa_item.
      if STRLEN( wa_item-eprice ) = 0.
        continue.
      endif.
      tmp_f = wa_item-eprice.

      data tm type int4.
      tm = wa_item-quantity.

      do tm times.
        arr->push_back( tmp_f ).
      enddo.
*      WRITE: / wa_item-id , wa_item-oid , wa_item-name, wa_item-price, wa_item-quantity, wa_item-owner, wa_item-eprice.
    ENDLOOP.

    LOOP AT arr->vector into arr->element.
      WRITE: / arr->element-index , arr->element-value.
    ENDLOOP.
    tmp_len = Z_ALGORITHM=>getprice( arr ).
*    write / tmp_len.
    data str type Z_STRING.
    str = tmp_len.
    row_1-eprice = str.
    modify ls_t_1 from row_1.
*    WRITE: / wa_onsale-id , wa_onsale-name, wa_onsale-price, wa_onsale-quantity, wa_onsale-owner, '|' , wa_onsale-eprice , '|'.
    arr->empty( ).

  endif.
endloop.

*****************************

  REFRESH lt_fcat_1.
  DATA: lv_pos3 TYPE i.

  lv_pos3 = lv_pos3 + 1.
  ls_fcat_1-fieldname = 'ID'.
  ls_fcat_1-coltext = 'ID'.
  ls_fcat_1-col_pos = lv_pos3.
  ls_fcat_1-outputlen = 3.
  APPEND ls_fcat_1 TO lt_fcat_1.
  lv_pos3 = lv_pos3 + 1.
  ls_fcat_1-fieldname = 'NAME'.
  ls_fcat_1-coltext = 'Item Name'.
  ls_fcat_1-col_pos = lv_pos3.
  ls_fcat_1-outputlen = 10.
  APPEND ls_fcat_1 TO lt_fcat_1.
  lv_pos3 = lv_pos3 + 1.
  ls_fcat_1-fieldname = 'PRICE'.
  ls_fcat_1-coltext = 'Item Price'.
  ls_fcat_1-col_pos = lv_pos3.
  ls_fcat_1-outputlen = 20.
  APPEND ls_fcat_1 TO lt_fcat_1.
  lv_pos3 = lv_pos3 + 1.
  ls_fcat_1-fieldname = 'QUANTITY'.
  ls_fcat_1-coltext = 'Item Quantity'.
  ls_fcat_1-col_pos = lv_pos3.
  ls_fcat_1-outputlen = 15.
  APPEND ls_fcat_1 TO lt_fcat_1.
  lv_pos3 = lv_pos3 + 1.
  ls_fcat_1-fieldname = 'OWNER'.
  ls_fcat_1-coltext = 'Item Owner'.
  ls_fcat_1-col_pos = lv_pos3.
  ls_fcat_1-outputlen = 15.
  APPEND ls_fcat_1 TO lt_fcat_1.
  lv_pos3 = lv_pos3 + 1.
  ls_fcat_1-fieldname = 'EPRICE'.
  ls_fcat_1-coltext = 'Expected Price'.
  ls_fcat_1-col_pos = lv_pos3.
  ls_fcat_1-outputlen = 20.
  APPEND ls_fcat_1 TO lt_fcat_1.



  if go_customer_container_1 is initial.
    create object go_customer_container_1
      exporting
        container_name = 'AVAILABLE_ITEMS_TABLE'.
    create object go_grid_1
      exporting
        i_parent = go_customer_container_1.
  endif.

  call method go_grid_1->set_table_for_first_display
    CHANGING
        it_outtab       = ls_t_1
        it_fieldcatalog = lt_fcat_1.

*********************************************************

data: ls_t_2 type table of ZTB_ITEM,
      row_2 TYPE ZTB_ITEM,
      go_grid_2 type ref to cl_gui_alv_grid,
      go_customer_container_2 type ref to cl_gui_custom_container,

      lt_fcat_2 TYPE lvc_t_fcat,
      ls_fcat_2 TYPE lvc_s_fcat.

  select * from ZTB_ITEM into table ls_t_2 where buyer = BUYER_USERNAME .

  sort ls_t_2 by id ASCENDING.

  REFRESH lt_fcat_2.
  DATA: lv_pos4 TYPE i value 0.

  lv_pos4 = lv_pos4 + 1.
  ls_fcat_2-fieldname = 'ID'.
  ls_fcat_2-coltext = 'ID'.
  ls_fcat_2-col_pos = lv_pos4.
  ls_fcat_2-outputlen = 3.
  APPEND ls_fcat_2 TO lt_fcat_2.
  lv_pos4 = lv_pos4 + 1.
  ls_fcat_2-fieldname = 'NAME'.
  ls_fcat_2-coltext = 'Item Name'.
  ls_fcat_2-col_pos = lv_pos4.
  ls_fcat_2-outputlen = 10.
  APPEND ls_fcat_2 TO lt_fcat_2.
  lv_pos4 = lv_pos4 + 1.
  ls_fcat_2-fieldname = 'PRICE'.
  ls_fcat_2-coltext = 'Item Price'.
  ls_fcat_2-col_pos = lv_pos4.
  ls_fcat_2-outputlen = 20.
  APPEND ls_fcat_2 TO lt_fcat_2.
  lv_pos4 = lv_pos4 + 1.
  ls_fcat_2-fieldname = 'QUANTITY'.
  ls_fcat_2-coltext = 'Item Quantity'.
  ls_fcat_2-col_pos = lv_pos4.
  ls_fcat_2-outputlen = 20.
  APPEND ls_fcat_2 TO lt_fcat_2.
  lv_pos4 = lv_pos4 + 1.
  ls_fcat_2-fieldname = 'OWNER'.
  ls_fcat_2-coltext = 'Item Owner'.
  ls_fcat_2-col_pos = lv_pos4.
  ls_fcat_2-outputlen = 15.
  APPEND ls_fcat_2 TO lt_fcat_2.
  lv_pos4 = lv_pos4 + 1.
  ls_fcat_2-fieldname = 'BUYER'.
  ls_fcat_2-coltext = 'Item BUYER'.
  ls_fcat_2-col_pos = lv_pos4.
  ls_fcat_2-outputlen = 15.
  APPEND ls_fcat_2 TO lt_fcat_2.
  lv_pos4 = lv_pos4 + 1.
  ls_fcat_2-fieldname = 'EPRICE'.
  ls_fcat_2-coltext = 'Expected Price'.
  ls_fcat_2-col_pos = lv_pos4.
  ls_fcat_2-outputlen = 20.
  APPEND ls_fcat_2 TO lt_fcat_2.



  if go_customer_container_2 is initial.
    create object go_customer_container_2
      exporting
        container_name = 'BOUGHT_ITEMS_TABLE'.
    create object go_grid_2
      exporting
        i_parent = go_customer_container_2.
  endif.

  call method go_grid_2->set_table_for_first_display
    CHANGING
        it_outtab       = ls_t_2
        it_fieldcatalog = lt_fcat_2.



endmodule.

data: ITEM_ID type string,
      ITEM_EPRICE type string.

module USER_COMMAND_9093 input.
  data obj_trans type ref to Z_TRANS.
        create object obj_trans exporting  input_id = ITEM_ID
                                           input_quantity = ITEM_QUANTITY
                                           input_buyer = BUYER_USERNAME
                                           input_eprice = ITEM_EPRICE.
  case ok_code.
    when 'BACK'.
      leave to screen 0.
    when 'BUYBTN'.
      result = Z_VALIDATE=>ALL_BUYER( INPUT_TRANS = obj_trans ).

      write / obj_trans->item_eprice.

      if result = 'F'.
        return.
      endif.

      result = obj_db_op->CREATE_ITEM(  input_trans = obj_trans ).

      Z_RESULT_INFO=>message( INPUT_RESULT = result INPUT_MESSAGE = 'Buy Item' ).

    when others.
      message ok_code type 'I'.
      leave to screen 0.
  endcase.
endmodule.