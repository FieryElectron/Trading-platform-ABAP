class Z_ARRAY_F definition
  public
  final
  create public .

*"* public components of class Z_ARRAY_F
*"* do not include other source files here!!!
public section.

  types:
    BEGIN OF vector_f,
         index TYPE INT4,
         value TYPE f,
         END OF vector_f .

  data ELEMENT type VECTOR_F .
  data:
    vector TYPE standard TABLE OF vector_f .
  data INDEX type Z_ID value 0. "#EC NOTEXT .

  methods PUSH_BACK
    importing
      value(INPUT_FLOAT) type F .
  methods GET_VALUE
    importing
      value(INPUT_INDEX) type INT4
    returning
      value(OUTPUT_FLOAT) type F .
  methods CHANGE_VALUE
    importing
      value(INPUT_INDEX) type INT4
      value(INPUT_FLOAT) type F .
  methods REMOVE_VALUE
    importing
      value(INPUT_INDEX) type INT4 .
  methods CORRECT_INDEX .
  methods CREATE_VALUE
    importing
      value(INPUT_LEN) type Z_INT
      value(INPUT_VALUE) type Z_INT .
  methods EMPTY .





method PUSH_BACK.
  element-index     = index.
  element-value     = INPUT_FLOAT.
  APPEND element TO vector.

  index = index + 1.
endmethod.

method GET_VALUE.
  if INPUT_INDEX >= index.
    message 'Exception index out of bounds!' type 'I'.
    OUTPUT_FLOAT = 0.
    return.
  endif.

  loop at vector into element.
    if element-index = INPUT_INDEX.
      OUTPUT_FLOAT = element-value.
      return.
    endif.
  endloop.

  OUTPUT_FLOAT = 0.

  message 'Exception something wrong with index management!(get value)' type 'I'.

endmethod.


method CHANGE_VALUE.
  if INPUT_INDEX >= index.
    message 'Exception index out of bounds!' type 'I'.
    return.
  endif.

  loop at vector into element.
    if element-index = INPUT_INDEX.
      element-value = INPUT_FLOAT.
      modify vector from element.
      return.
    endif.
  endloop.

  message 'Exception something wrong with index management!(change value)' type 'I'.

endmethod.


method REMOVE_VALUE.
  if INPUT_INDEX >= index.
    message 'Exception index out of bounds!' type 'I'.
    return.
  endif.

  loop at vector into element.
    if element-index = INPUT_INDEX.
      delete vector where index = INPUT_INDEX.
      CORRECT_INDEX( ).
      return.
    endif.
  endloop.

  message 'Exception something wrong with index management!(remove value)' type 'I'.
endmethod.




method CORRECT_INDEX.
  data idx type i value 0.

  LOOP AT vector into element.
    element-index = idx.
    modify vector from element.
    idx = idx + 1.
    index = idx.
  ENDLOOP.
endmethod.



method CREATE_VALUE.
  data float type f.
  float = INPUT_VALUE.
  do INPUT_LEN times.
    push_back( float ).
  enddo.
endmethod.

method EMPTY.
  data t type i.
  t = index.
  do t times.
    remove_value( 0 ).
  enddo.
endmethod.

