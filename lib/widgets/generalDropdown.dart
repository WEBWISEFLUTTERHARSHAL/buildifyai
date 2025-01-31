import 'package:Buildify_AI/utils/colors.dart';
import 'package:flutter/material.dart';

class GeneralDropdown extends StatelessWidget {
  String hintText;
  List<DropdownMenuItem> items;
  ValueNotifier selectedValue = ValueNotifier(null);
  ValueSetter? onChanged;

  GeneralDropdown({
    super.key,
    required this.hintText,
    required this.selectedValue,
    this.onChanged,
    this.items = const [],
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selectedValue,
      builder: (context, selectedVal, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: white,
          ),
          child: DropdownButton(
            value: selectedValue.value,
            dropdownColor: white,
            menuMaxHeight: 250,
            items: items,
            isDense: true,
            isExpanded: true,
            onChanged: (value) {
              selectedValue.value = value;
              if (onChanged != null) {
                onChanged!(value);
              }
            },
            borderRadius: BorderRadius.circular(10),
            padding: EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 20,
            ),
            hint: Text(
              hintText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: lightGreyTheme,
              ),
            ),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: black,
            ),
            icon: Icon(
              Icons.arrow_drop_down_outlined,
            ),
            underline: SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
