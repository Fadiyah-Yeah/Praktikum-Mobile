
import 'package:flutter/material.dart';

class SearchField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;

  const SearchField({
    super.key,
    required this.controller,
    this.hintText = 'Cari karakter...',
    this.onChanged,
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  @override
  void initState() {
    super.initState();

    // Memantau perubahan teks agar tombol hapus muncul otomatis.
    widget.controller.addListener(_updateState);
  }

  void _updateState() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateState);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      onChanged: widget.onChanged,
      style: const TextStyle(
        fontFamily: 'Nunito',
        fontSize: 14,
        color: Color(0xFF302522),
      ),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: const TextStyle(
          color: Color(0xFF9B8A7B),
          fontFamily: 'Nunito',
          fontSize: 14,
        ),
        prefixIcon: const Icon(
          Icons.search,
          color: Color(0xFF6B5B4E),
        ),

        // Tombol hapus hanya muncul jika kolom tidak kosong.
        suffixIcon: widget.controller.text.isNotEmpty
            ? IconButton(
                onPressed: () {
                  widget.controller.clear();
                  widget.onChanged?.call('');
                },
                icon: const Icon(
                  Icons.close,
                  color: Color(0xFF6B5B4E),
                ),
              )
            : null,
        filled: true,
        fillColor: const Color(0xFFFFF8E7),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFDCC6A9),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFDCC6A9),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFA3C86D),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
