import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final String? prefixText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Function()? onSuffixIconTap;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final Function()? onTap;
  final String? initialValue;
  final TextEditingController? controller;
  final bool obscureText;
  final bool readOnly;
  final bool isRequired;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final bool autofocus;
  final Color? fillColor;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final bool showBorder;
  final double borderRadius;
  final EdgeInsets contentPadding;

  const CustomTextField({
    Key? key,
    required this.label,
    this.hint,
    this.prefixText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.initialValue,
    this.controller,
    this.obscureText = false,
    this.readOnly = false,
    this.isRequired = false,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.maxLines = 1,
    this.autofocus = false,
    this.fillColor,
    this.textInputAction,
    this.focusNode,
    this.showBorder = true,
    this.borderRadius = 12.0,
    this.contentPadding = const EdgeInsets.all(16.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
              if (isRequired)
                Text(
                  ' *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
            ],
          ),
        ),

        // Text field
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          obscureText: obscureText,
          readOnly: readOnly,
          textInputAction: textInputAction,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          onTap: onTap,
          maxLines: maxLines,
          autofocus: autofocus,
          focusNode: focusNode,
          inputFormatters: inputFormatters,
          style: TextStyle(color: Colors.grey[800], fontSize: 15),
          decoration: InputDecoration(
            filled: true,
            fillColor: fillColor ?? Colors.grey.shade50,
            contentPadding: contentPadding,
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            prefixText: prefixText,
            prefixStyle: TextStyle(
              color: Colors.grey[800],
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon:
                prefixIcon != null
                    ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Icon(
                        prefixIcon,
                        size: 20,
                        color: Colors.grey[600],
                      ),
                    )
                    : null,
            suffixIcon:
                suffixIcon != null
                    ? GestureDetector(
                      onTap: onSuffixIconTap,
                      child: Icon(
                        suffixIcon,
                        size: 20,
                        color: Colors.grey[600],
                      ),
                    )
                    : null,
            enabledBorder:
                showBorder
                    ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(borderRadius),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1.0,
                      ),
                    )
                    : InputBorder.none,
            focusedBorder:
                showBorder
                    ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(borderRadius),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 1.5,
                      ),
                    )
                    : InputBorder.none,
            errorBorder:
                showBorder
                    ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(borderRadius),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                        width: 1.0,
                      ),
                    )
                    : InputBorder.none,
            focusedErrorBorder:
                showBorder
                    ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(borderRadius),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                        width: 1.5,
                      ),
                    )
                    : InputBorder.none,
            floatingLabelBehavior: FloatingLabelBehavior.never,
          ),
        ),
      ],
    );
  }
}

class CustomDropdown<T> extends StatelessWidget {
  final String label;
  final String hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final Function(T?) onChanged;
  final bool isRequired;
  final bool isEnabled;
  final String? Function(T?)? validator;
  final IconData? prefixIcon;
  final double borderRadius;
  final Color? fillColor;

  const CustomDropdown({
    Key? key,
    required this.label,
    required this.hint,
    this.value,
    required this.items,
    required this.onChanged,
    this.isRequired = false,
    this.isEnabled = true,
    this.validator,
    this.prefixIcon,
    this.borderRadius = 12.0,
    this.fillColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
              if (isRequired)
                Text(
                  ' *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
            ],
          ),
        ),

        // Dropdown
        DropdownButtonFormField<T>(
          value: value,
          hint: Text(
            hint,
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          style: TextStyle(color: Colors.grey[800], fontSize: 15),
          onChanged: isEnabled ? onChanged : null,
          validator: validator,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.grey[600],
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: fillColor ?? Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            prefixIcon:
                prefixIcon != null
                    ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Icon(
                        prefixIcon,
                        size: 20,
                        color: Colors.grey[600],
                      ),
                    )
                    : null,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 1.0,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 1.5,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1.0),
            ),
          ),
          items: items,
          menuMaxHeight: 300,
          isExpanded: true,
          dropdownColor: Colors.white,
        ),
      ],
    );
  }
}

class CustomDatePicker extends StatelessWidget {
  final String label;
  final String hint;
  final DateTime value;
  final Function(DateTime) onChanged;
  final bool isRequired;
  final double borderRadius;
  final Color? fillColor;

  const CustomDatePicker({
    Key? key,
    required this.label,
    required this.hint,
    required this.value,
    required this.onChanged,
    this.isRequired = false,
    this.borderRadius = 12.0,
    this.fillColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
              if (isRequired)
                Text(
                  ' *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
            ],
          ),
        ),

        // Date Picker
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: value,
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
              builder: (BuildContext context, Widget? child) {
                return Theme(
                  data: ThemeData.light().copyWith(
                    colorScheme: ColorScheme.light(
                      primary: Theme.of(context).primaryColor,
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: Colors.black,
                    ),
                    dialogBackgroundColor: Colors.white,
                  ),
                  child: child!,
                );
              },
            );

            if (picked != null) {
              onChanged(picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: fillColor ?? Colors.grey.shade50,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: Colors.grey.shade300, width: 1.0),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 12),
                Text(
                  value.toString().split(' ')[0],
                  style: TextStyle(color: Colors.grey[800], fontSize: 15),
                ),
                const Spacer(),
                Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double borderRadius;
  final double height;
  final double? width;
  final IconData? icon;
  final bool isOutlined;
  final bool isFullWidth;
  final EdgeInsetsGeometry padding;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 12.0,
    this.height = 50.0,
    this.width,
    this.icon,
    this.isOutlined = false,
    this.isFullWidth = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final btnColor = backgroundColor ?? Theme.of(context).primaryColor;
    final txtColor = textColor ?? Colors.white;

    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.transparent : btnColor,
          foregroundColor: isOutlined ? btnColor : txtColor,
          elevation: isOutlined ? 0 : 0,
          shadowColor: Colors.black.withOpacity(0.1),
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side:
                isOutlined
                    ? BorderSide(color: btnColor, width: 1.5)
                    : BorderSide.none,
          ),
          disabledBackgroundColor: Colors.grey[300],
          disabledForegroundColor: Colors.grey[600],
        ),
        child:
            isLoading
                ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    color: isOutlined ? btnColor : txtColor,
                  ),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}

class CustomSegmentedButton extends StatelessWidget {
  final List<String> options;
  final int selectedIndex;
  final Function(int) onChanged;
  final double height;
  final double borderRadius;

  const CustomSegmentedButton({
    Key? key,
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
    this.height = 45.0,
    this.borderRadius = 12.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        children: List.generate(options.length, (index) {
          final isSelected = index == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(index),
              child: Container(
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(borderRadius),
                  boxShadow:
                      isSelected
                          ? [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                          : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  options[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[800],
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
