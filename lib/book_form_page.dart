import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookFormPage extends StatefulWidget {
  final Map<String, dynamic>? bookData;
  const BookFormPage({super.key, this.bookData});

  @override
  State<BookFormPage> createState() => _BookFormPageState();
}

class _BookFormPageState extends State<BookFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _judulCtrl = TextEditingController();
  final _hargaCtrl = TextEditingController();
  final _jumlahCtrl = TextEditingController();
  final _tglMasukCtrl = TextEditingController();
  final _volumeCtrl = TextEditingController();
  final _penulisCtrl = TextEditingController();
  final _penerbitCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.bookData != null) {
      _judulCtrl.text = widget.bookData!['judul'];
      _hargaCtrl.text = widget.bookData!['harga'].toString();
      _jumlahCtrl.text = widget.bookData!['jumlah'].toString();
      _tglMasukCtrl.text = widget.bookData!['tanggal_masuk'];
      _volumeCtrl.text = widget.bookData!['volume'].toString();
      _penulisCtrl.text = widget.bookData!['penulis'];
      _penerbitCtrl.text = widget.bookData!['penerbit'];
    }
  }

  Future<void> _saveBook() async {
    if (!_formKey.currentState!.validate()) return;
    final data = {
      'judul': _judulCtrl.text,
      'harga': int.parse(_hargaCtrl.text),
      'jumlah': int.parse(_jumlahCtrl.text),
      'tanggal_masuk': _tglMasukCtrl.text,
      'volume': int.parse(_volumeCtrl.text),
      'penulis': _penulisCtrl.text,
      'penerbit': _penerbitCtrl.text,
    };

    try {
      if (widget.bookData == null) {
        await Supabase.instance.client.from('books').insert(data);
      } else {
        await Supabase.instance.client.from('books').update(data).eq('id', widget.bookData!['id']);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.bookData != null ? 'Deef Books - Edit' : 'Deef Books - Tambah')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildInput('Judul Buku', _judulCtrl),
            Row(children: [Expanded(child: _buildInput('Harga (Rp)', _hargaCtrl, isNumber: true)), const SizedBox(width: 12), Expanded(child: _buildInput('Stok', _jumlahCtrl, isNumber: true))]),
            Row(children: [Expanded(child: _buildInput('Volume', _volumeCtrl, isNumber: true)), const SizedBox(width: 12), Expanded(child: _buildInput('Tgl Masuk (YYYY-MM-DD)', _tglMasukCtrl))]),
            _buildInput('Penulis', _penulisCtrl),
            _buildInput('Penerbit', _penerbitCtrl),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _saveBook, child: Text(widget.bookData != null ? 'SIMPAN' : 'TAMBAH KE DEEF BOOKS'))
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController ctrl, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(labelText: label),
        validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
      ),
    );
  }
}